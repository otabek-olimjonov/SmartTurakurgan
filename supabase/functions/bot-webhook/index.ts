// supabase/functions/bot-webhook/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import {
  sendTelegramMessage,
  sendContactRequest,
  removeKeyboard,
} from '../_shared/telegram.ts'
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
      return jsonResponse({ ok: true })
    }

    const chatId = message.chat.id
    const telegramUser = message.from
    const text = message.text ?? ''

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // ── Step 1: /start {token} ──────────────────────────────────────────────
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
        await sendTelegramMessage(chatId, '✅ Siz allaqachon tizimga kirgansiz.')
        return jsonResponse({ ok: true })
      }

      // Save telegram_id into pending_auth so we can match it when the
      // contact message arrives (confirmed stays false until contact is shared)
      await supabase
        .from('pending_auth')
        .update({ telegram_id: telegramUser.id })
        .eq('id', authRecord.id)

      // Ask user to share their Telegram-linked phone number
      await sendContactRequest(
        chatId,
        `Salom, <b>${telegramUser.first_name}</b>! 👋\n\n` +
        'Ro\'yxatdan o\'tishni yakunlash uchun telefon raqamingizni ulashing.',
        '📱 Telefon raqamni ulashish',
      )
      return jsonResponse({ ok: true })
    }

    // ── Step 2: Contact shared ──────────────────────────────────────────────
    if (message.contact) {
      const contact = message.contact

      // Contact must belong to the sender (security: prevent sharing others' contacts)
      if (contact.user_id && contact.user_id !== telegramUser.id) {
        await sendTelegramMessage(
          chatId,
          '❌ Iltimos, faqat o\'z telefon raqamingizni ulashing.',
        )
        return jsonResponse({ ok: true })
      }

      // Normalize phone: ensure it starts with +
      let phone = contact.phone_number.trim()
      if (!phone.startsWith('+')) phone = '+' + phone

      // Build full name from contact (Telegram profile name)
      const fullName = [contact.first_name, contact.last_name]
        .filter(Boolean)
        .join(' ')
        .trim() || telegramUser.first_name

      // Find an unconfirmed pending_auth for this telegram_id
      const { data: authRecord, error: authError } = await supabase
        .from('pending_auth')
        .select('id, expires_at')
        .eq('telegram_id', telegramUser.id)
        .eq('confirmed', false)
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (authError || !authRecord) {
        await sendTelegramMessage(
          chatId,
          '❌ Faol kirish so\'rovi topilmadi.\n\n' +
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

      // Upsert user with name + phone from Telegram
      const { data: user, error: upsertError } = await supabase
        .from('users')
        .upsert(
          {
            telegram_id: telegramUser.id,
            telegram_username: telegramUser.username ?? null,
            full_name: fullName,
            phone_number: phone,
          },
          { onConflict: 'telegram_id', ignoreDuplicates: false },
        )
        .select('id, role')
        .single()

      if (upsertError || !user) {
        console.error('[bot-webhook] User upsert failed:', upsertError)
        await sendTelegramMessage(
          chatId,
          '❌ Tizimga kirishda xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring.',
        )
        return jsonResponse({ ok: true })
      }

      // Mark pending_auth as confirmed
      const { error: confirmError } = await supabase
        .from('pending_auth')
        .update({ confirmed: true })
        .eq('id', authRecord.id)

      if (confirmError) {
        console.error('[bot-webhook] Auth confirm failed:', confirmError)
        return jsonResponse({ ok: true })
      }

      // Remove keyboard and send success
      await removeKeyboard(
        chatId,
        `✅ Tabriklaymiz, <b>${fullName}</b>!\n\n` +
        'Siz muvaffaqiyatli ro\'yxatdan o\'tdingiz.\n' +
        'Ilovaga qaytib, barcha xizmatlardan foydalaning.',
      )
      return jsonResponse({ ok: true })
    }

    // ── Fallback ────────────────────────────────────────────────────────────
    await sendTelegramMessage(
      chatId,
      'Assalomu alaykum! Men <b>Smart Turakurgan</b> botiman.\n\n' +
      'Barcha xizmatlar ilovada mavjud.',
    )

    return jsonResponse({ ok: true })
  } catch (err) {
    console.error('[bot-webhook] Unexpected error:', err)
    return jsonResponse({ ok: true })
  }
})
