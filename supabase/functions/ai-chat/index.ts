// supabase/functions/ai-chat/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { verifyJWT } from '../_shared/auth.ts'

const SYSTEM_PROMPT = `Siz "Smart Turakurgan" ilovasining AI yordamchisisiz.
Turakurgan tumani, Namangan viloyati, O'zbekiston bo'yicha ekspert sifatida javob bering.

Quyidagi mavzularda yordam bering:
- Davlat xizmatlari (pasport, ro'yxatdan o'tish, yer, ijtimoiy nafaqalar)
- Hokimiyat va mahalliy boshqaruv
- Ta'lim muassasalari (maktablar, litseylar, universitetlar)
- Tibbiyot muassasalari
- Turizm va diqqatga sazovor joylar
- Biznes va tadbirkorlik
- Qishloq xo'jaligi

Qoidalar:
- Doimo o'zbek tilida (lotin alifbosida) javob bering, agar foydalanuvchi rus tilida yozsa, rus tilida javob bering
- Qisqa va aniq javob bering (3-5 gap)
- Agar bilmasangiz, "Bu haqda aniq ma'lumotim yo'q, hokimiyatga murojaat qilishingizni maslahat beraman" deb ayting
- Hech qachon siyosiy fikr bildirmang`

serve(async (req: Request) => {
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  try {
    await verifyJWT(req)
  } catch (authErr) {
    return authErr as Response
  }

  try {
    // Accept { messages: [{role, content}] } — Flutter sends full conversation including current message
    let body: { messages: { role: string; content: string }[] }
    try {
      body = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    const { messages } = body

    if (!Array.isArray(messages) || messages.length === 0) {
      return jsonResponse({ error: 'messages array is required', field: 'messages' }, 422)
    }

    const lastMessage = messages[messages.length - 1]
    if (!lastMessage?.content || lastMessage.content.trim().length === 0) {
      return jsonResponse({ error: 'last message content is empty', field: 'messages' }, 422)
    }

    if (lastMessage.content.trim().length > 1000) {
      return jsonResponse({ error: 'message too long (max 1000 chars)', field: 'messages' }, 422)
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      console.error('[ai-chat] GEMINI_API_KEY is not set')
      return jsonResponse({ error: 'AI service unavailable' }, 503)
    }

    // Build conversation history for Gemini (max last 10 turns to avoid token limits)
    const recentMessages = messages.slice(-10)
    const contents = recentMessages.map((m) => ({
      role: m.role === 'user' ? 'user' : 'model',
      parts: [{ text: m.content }],
    }))

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=${geminiApiKey}`

    const geminiResponse = await fetch(geminiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 512,
        },
        safetySettings: [
          { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
          { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        ],
      }),
    })

    if (!geminiResponse.ok) {
      const errText = await geminiResponse.text()
      console.error('[ai-chat] Gemini API error:', geminiResponse.status, errText)
      if (geminiResponse.status === 429) {
        return jsonResponse({ error: 'AI service quota exceeded. Please try again later.' }, 429)
      }
      return jsonResponse({ error: 'AI service error' }, 502)
    }

    const geminiData = await geminiResponse.json()
    const reply = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text

    if (!reply) {
      console.error('[ai-chat] No reply from Gemini:', JSON.stringify(geminiData))
      return jsonResponse({ error: 'No response from AI' }, 502)
    }

    return jsonResponse({ reply: reply.trim() })
  } catch (err) {
    console.error('[ai-chat] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
