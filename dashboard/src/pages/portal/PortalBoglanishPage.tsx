import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { supabase } from '../../lib/supabase'
import { Phone, MapPin, Clock, Mail, CheckCircle2, SendHorizonal } from 'lucide-react'

const schema = z.object({
  full_name: z.string().min(3, 'Ismingizni kiriting (kamida 3 ta harf)'),
  phone: z.string().regex(/^\+?[0-9]{9,13}$/, "To'g'ri telefon raqam kiriting"),
  address: z.string().min(5, 'Manzilingizni kiriting'),
  message: z.string().min(20, 'Murojaatingizni batafsilroq yozing (kamida 20 ta belgi)'),
})
type FormData = z.infer<typeof schema>

const CONTACT_ITEMS = [
  {
    icon: MapPin,
    label: 'Manzil',
    value: "Namangan viloyati, Turakurgan tumani, Markaziy ko'cha, 1",
    color: 'text-[#5856D6]',
    bg: 'bg-[#5856D6]/10',
  },
  {
    icon: Phone,
    label: 'Telefon',
    value: '+998 73 394 00 00',
    href: 'tel:+998733940000',
    color: 'text-[#1D9E75]',
    bg: 'bg-[#1D9E75]/10',
  },
  {
    icon: Mail,
    label: 'Email',
    value: 'hokimiyat@turakurgan.uz',
    href: 'mailto:hokimiyat@turakurgan.uz',
    color: 'text-[#007AFF]',
    bg: 'bg-[#007AFF]/10',
  },
  {
    icon: Clock,
    label: 'Ish vaqti',
    value: 'Dushanba – Juma: 9:00 – 18:00',
    color: 'text-[#FF9500]',
    bg: 'bg-[#FF9500]/10',
  },
]

export default function PortalBoglanishPage() {
  const [submitted, setSubmitted] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) })

  async function onSubmit(data: FormData) {
    setServerError(null)
    const { error } = await supabase.from('murojaatlar').insert({
      full_name: data.full_name,
      phone: data.phone,
      address: data.address,
      message: data.message,
      status: 'pending',
    })
    if (error) {
      setServerError("Murojaat yuborishda xato yuz berdi. Iltimos, qaytadan urinib ko'ring.")
      return
    }
    setSubmitted(true)
    reset()
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <h1 className="text-xl font-medium text-[#0A0A0A] mb-2">Bog'lanish</h1>
      <p className="text-sm text-[#888780] mb-8">
        Tuman hokimiyati bilan bog'laning yoki rasmiy murojaat yuboring.
      </p>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Left: contact info */}
        <div className="lg:col-span-2 flex flex-col gap-3">
          <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-1">Aloqa ma'lumotlari</h2>

          {CONTACT_ITEMS.map(({ icon: Icon, label, value, href, color, bg }) => (
            <div key={label} className="bg-white rounded-xl p-4 flex items-start gap-3">
              <div className={`w-9 h-9 rounded-lg flex items-center justify-center shrink-0 ${bg}`}>
                <Icon size={16} className={color} strokeWidth={1.8} />
              </div>
              <div>
                <p className="text-[11px] text-[#888780]">{label}</p>
                {href ? (
                  <a href={href} className="text-sm text-[#0A0A0A] hover:text-[#1D9E75] transition-colors mt-0.5 block">
                    {value}
                  </a>
                ) : (
                  <p className="text-sm text-[#0A0A0A] mt-0.5">{value}</p>
                )}
              </div>
            </div>
          ))}

          {/* Static map placeholder */}
          <div className="bg-white rounded-xl overflow-hidden mt-1">
            <a
              href="https://maps.google.com/?q=41.0,71.1"
              target="_blank"
              rel="noopener noreferrer"
              className="block"
            >
              <div className="h-36 bg-[#1D9E75]/8 flex flex-col items-center justify-center gap-2 hover:bg-[#1D9E75]/12 transition-colors">
                <MapPin size={22} className="text-[#1D9E75]" strokeWidth={1.5} />
                <p className="text-xs text-[#1D9E75] font-medium">Xaritada ko'rish</p>
              </div>
            </a>
          </div>
        </div>

        {/* Right: murojaat form */}
        <div className="lg:col-span-3">
          <div className="bg-white rounded-xl p-6">
            <h2 className="text-sm font-medium text-[#0A0A0A] mb-1">Murojaat yozish</h2>
            <p className="text-xs text-[#888780] mb-5">
              Barcha murojaatlar ko'rib chiqiladi va javob beriladi.
            </p>

            {submitted ? (
              <div className="py-10 flex flex-col items-center gap-3 text-center">
                <CheckCircle2 size={40} className="text-[#1D9E75]" strokeWidth={1.5} />
                <p className="text-base font-medium text-[#0A0A0A]">Murojaatingiz qabul qilindi!</p>
                <p className="text-sm text-[#888780] max-w-xs">
                  Tez orada siz bilan bog'lanamiz. Telefon raqamingizni tekshirib qo'ying.
                </p>
                <button
                  onClick={() => setSubmitted(false)}
                  className="mt-2 text-sm text-[#1D9E75] hover:underline"
                >
                  Yangi murojaat yozish
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
                <div>
                  <label className="block text-xs font-medium text-[#0A0A0A] mb-1.5">
                    To'liq ism <span className="text-[#E24B4A]">*</span>
                  </label>
                  <input
                    {...register('full_name')}
                    placeholder="Familiya Ism Sharifingiz"
                    className="w-full border border-[#E8E6E1] rounded-lg px-3 py-2.5 text-sm text-[#0A0A0A] placeholder:text-[#888780] focus:outline-none focus:ring-1 focus:ring-[#1D9E75] focus:border-[#1D9E75] transition-colors"
                  />
                  {errors.full_name && (
                    <p className="text-[11px] text-[#E24B4A] mt-1">{errors.full_name.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#0A0A0A] mb-1.5">
                    Telefon raqam <span className="text-[#E24B4A]">*</span>
                  </label>
                  <input
                    {...register('phone')}
                    placeholder="+998 90 000 00 00"
                    className="w-full border border-[#E8E6E1] rounded-lg px-3 py-2.5 text-sm text-[#0A0A0A] placeholder:text-[#888780] focus:outline-none focus:ring-1 focus:ring-[#1D9E75] focus:border-[#1D9E75] transition-colors"
                  />
                  {errors.phone && (
                    <p className="text-[11px] text-[#E24B4A] mt-1">{errors.phone.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#0A0A0A] mb-1.5">
                    Manzil <span className="text-[#E24B4A]">*</span>
                  </label>
                  <input
                    {...register('address')}
                    placeholder="Tuman, mahalla, ko'cha"
                    className="w-full border border-[#E8E6E1] rounded-lg px-3 py-2.5 text-sm text-[#0A0A0A] placeholder:text-[#888780] focus:outline-none focus:ring-1 focus:ring-[#1D9E75] focus:border-[#1D9E75] transition-colors"
                  />
                  {errors.address && (
                    <p className="text-[11px] text-[#E24B4A] mt-1">{errors.address.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#0A0A0A] mb-1.5">
                    Murojaat matni <span className="text-[#E24B4A]">*</span>
                  </label>
                  <textarea
                    {...register('message')}
                    rows={5}
                    placeholder="Murojaatingizni batafsil yozing..."
                    className="w-full border border-[#E8E6E1] rounded-lg px-3 py-2.5 text-sm text-[#0A0A0A] placeholder:text-[#888780] focus:outline-none focus:ring-1 focus:ring-[#1D9E75] focus:border-[#1D9E75] transition-colors resize-none"
                  />
                  {errors.message && (
                    <p className="text-[11px] text-[#E24B4A] mt-1">{errors.message.message}</p>
                  )}
                </div>

                {serverError && (
                  <p className="text-xs text-[#E24B4A] bg-[#E24B4A]/8 rounded-lg px-3 py-2">{serverError}</p>
                )}

                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="flex items-center justify-center gap-2 bg-[#1D9E75] text-white text-sm px-6 py-3 rounded-lg hover:bg-[#178a65] transition-colors disabled:opacity-60 disabled:cursor-not-allowed font-medium"
                >
                  {isSubmitting ? (
                    <span className="inline-block w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                  ) : (
                    <SendHorizonal size={15} strokeWidth={2} />
                  )}
                  {isSubmitting ? 'Yuborilmoqda...' : 'Murojaat yuborish'}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
