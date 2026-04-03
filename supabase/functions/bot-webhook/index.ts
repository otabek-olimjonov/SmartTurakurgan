// supabase/functions/bot-webhook/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { sendTelegramMessage } from '../_shared/telegram.ts'
import type { TelegramUpdate } from '../_shared/telegram.ts'

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // Verify webhook secret to prevent spoofed requests
  const webhookSecret = Deno.env.get('TELEGRAM_WEBHOOK_SECRET')
  const incomingSecret = req.headers.get('X-Telegram-Bot-Api-Secret-Token')
  if (!webhookSecret || incomingSecret !== webhookSecret) {
    return jsonResponse({ error: 'Unauthorized' }, 401)
  }

  try {
    let update: TelegramUpdate
    try {
      update = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    const message = update.message
    if (!message || !message.from) {
      // Ignore non-message updates (e.g. channel posts, edited messages)
      return jsonResponse({ ok: true })
    }

    const chatId = message.chat.id
    const telegramUser = message.from
    const text = message.text ?? ''

    // Handle /start {token} command
    if (text.startsWith('/start')) {
      const parts = text.split(' ')
      const token = parts[1]?.trim()

      if (!token) {
        await sendTelegramMessage(
          chatId,
          'Salom! <b>Smart Turakurgan</b> ilovasiga xush kelibsiz.\n\n' +
          'Ilovani ochib, "Telegram orqali kirish" tugmasini bosing.',
        )
        return jsonResponse({ ok: true })
      }

      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      )

      // Look up the pending auth token
      const { data: authRecord, error: authError } = await supabase
        .from('pending_auth')
        .select('id, confirmed, expires_at, device_id')
        .eq('token', token)
        .single()

      if (authError || !authRecord) {
        await sendTelegramMessage(
          chatId,
          '❌ Kirish havolasi topilmadi yoki muddati o\'tgan.\n\n' +
          'Iltimos, ilovada qaytadan urinib ko\'ring.',
        )
        return jsonResponse({ ok: true })
      }

      if (new Date(authRecord.expires_at) < new Date()) {
        await sendTelegramMessage(
          chatId,
          '⏰ Kirish havolasining muddati tugagan.\n\n' +
          'Iltimos, ilovada qaytadan urinib ko\'ring.',
        )
        return jsonResponse({ ok: true })
      }

      if (authRecord.confirmed) {
        await sendTelegramMessage(
          chatId,
          '✅ Siz allaqachon tizimga kirgansiz.',
        )
        return jsonResponse({ ok: true })
      }

      // Upsert the user record
      const { data: user, error: upsertError } = await supabase
        .from('users')
        .upsert(
          {
            telegram_id: telegramUser.id,
            telegram_username: telegramUser.username ?? null,
          },
          { onConflict: 'telegram_id', ignoreDuplicates: false },
        )
        .select('id, role, full_name')
        .single()

      if (upsertError || !user) {
        console.error('[bot-webhook] User upsert failed:', upsertError)
        await sendTelegramMessage(
          chatId,
          '❌ Tizimga kirishda xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring.',
        )
        return jsonResponse({ ok: true })
      }

      // Mark the pending_auth as confirmed
      const { error: confirmError } = await supabase
        .from('pending_auth')
        .update({ confirmed: true, telegram_id: telegramUser.id })
        .eq('id', authRecord.id)

      if (confirmError) {
        console.error('[bot-webhook] Auth confirm failed:', confirmError)
        return jsonResponse({ ok: true })
      }

      // Determine if this is a new or returning user
      const isNewUser = !user.full_name
      const greeting = isNewUser
        ? `Xush kelibsiz, <b>${telegramUser.first_name}</b>! 🎉\n\n` +
          'Ilovaga qaytib, ro\'yxatdan o\'tishni yakunlang.'
        : `Xush kelibsiz, <b>${user.full_name ?? telegramUser.first_name}</b>! ✅\n\n` +
          'Ilovaga qaytib, xizmatlardan foydalaning.'

      await sendTelegramMessage(chatId, greeting)
      return jsonResponse({ ok: true })
    }

    // Handle any other messages
    await sendTelegramMessage(
      chatId,
      'Assalomu alaykum! Men <b>Smart Turakurgan</b> botiman.\n\n' +
      'Barcha xizmatlar ilovada mavjud. Ilovani yuklab oling: ' +
      'https://smartturakurgan.uz',
    )

    return jsonResponse({ ok: true })
  } catch (err) {
    console.error('[bot-webhook] Unexpected error:', err)
    // Always return 200 to Telegram — otherwise it will retry
    return jsonResponse({ ok: true })
  }
})
