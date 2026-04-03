// supabase/functions/_shared/telegram.ts

const TELEGRAM_API_BASE = 'https://api.telegram.org/bot'

function botToken(): string {
  const token = Deno.env.get('TELEGRAM_BOT_TOKEN')
  if (!token) throw new Error('TELEGRAM_BOT_TOKEN is not set')
  return token
}

/**
 * Sends a plain text message to a Telegram chat.
 */
export async function sendTelegramMessage(
  chatId: number,
  text: string,
): Promise<void> {
  const url = `${TELEGRAM_API_BASE}${botToken()}/sendMessage`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: chatId, text, parse_mode: 'HTML' }),
  })

  if (!res.ok) {
    const body = await res.text()
    console.error(`[telegram] sendMessage failed: ${res.status} ${body}`)
  }
}

/**
 * Sends a message with an inline keyboard to a Telegram chat.
 */
export async function sendTelegramKeyboard(
  chatId: number,
  text: string,
  keyboard: TelegramInlineKeyboard,
): Promise<void> {
  const url = `${TELEGRAM_API_BASE}${botToken()}/sendMessage`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
      reply_markup: { inline_keyboard: keyboard },
    }),
  })

  if (!res.ok) {
    const body = await res.text()
    console.error(`[telegram] sendKeyboard failed: ${res.status} ${body}`)
  }
}

// ---- Types ----

export interface TelegramUpdate {
  update_id: number
  message?: TelegramMessage
  callback_query?: TelegramCallbackQuery
}

export interface TelegramMessage {
  message_id: number
  from: TelegramUser
  chat: TelegramChat
  date: number
  text?: string
}

export interface TelegramCallbackQuery {
  id: string
  from: TelegramUser
  message?: TelegramMessage
  data?: string
}

export interface TelegramUser {
  id: number
  is_bot: boolean
  first_name: string
  last_name?: string
  username?: string
}

export interface TelegramChat {
  id: number
  type: string
  first_name?: string
  username?: string
}

export type TelegramInlineKeyboard = Array<
  Array<{ text: string; callback_data?: string; url?: string }>
>
