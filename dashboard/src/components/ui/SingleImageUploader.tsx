import { useRef, useState } from 'react'
import { User, Loader2 } from 'lucide-react'
import { supabase } from '../../lib/supabase'

interface Props {
  value: string | null
  onChange: (url: string | null) => void
  folder: string
  label?: string
  placeholder?: React.ReactNode
  disabled?: boolean
  shape?: 'circle' | 'square'
}

export default function SingleImageUploader({
  value,
  onChange,
  folder,
  label = 'Rasm',
  placeholder,
  disabled,
  shape = 'circle',
}: Props) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [uploading, setUploading] = useState(false)

  async function handleFile(file: File) {
    setUploading(true)
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() ?? 'jpg'
      const path = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
      const { error } = await supabase.storage.from('images').upload(path, file, {
        cacheControl: '3600',
        upsert: false,
      })
      if (error) {
        console.error('[SingleImageUploader] upload error:', error.message)
        return
      }
      const { data: { publicUrl } } = supabase.storage.from('images').getPublicUrl(path)
      onChange(publicUrl)
    } finally {
      setUploading(false)
    }
  }

  const borderRadius = shape === 'circle' ? 'rounded-full' : 'rounded-xl'

  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-xs font-medium text-[#0A0A0A]">{label}</label>
      <div className="flex items-center gap-4">
        {/* Preview */}
        <div
          className={`w-20 h-20 ${borderRadius} border border-[#E8E6E1] bg-[#F7F6F3] overflow-hidden flex items-center justify-center flex-shrink-0`}
        >
          {value ? (
            <img src={value} alt="" className="w-full h-full object-cover" />
          ) : (
            placeholder ?? <User size={28} className="text-[#E8E6E1]" />
          )}
        </div>

        {/* Actions */}
        <div className="flex flex-col gap-1.5">
          <input
            ref={inputRef}
            type="file"
            accept="image/*"
            className="hidden"
            disabled={disabled || uploading}
            onChange={e => {
              const f = e.target.files?.[0]
              if (f) handleFile(f)
              e.target.value = ''
            }}
          />
          <button
            type="button"
            onClick={() => inputRef.current?.click()}
            disabled={disabled || uploading}
            className="flex items-center gap-1.5 h-8 px-3 rounded-lg border border-[#E8E6E1] text-xs font-medium text-[#0A0A0A] bg-white hover:bg-[#F7F6F3] transition-colors disabled:opacity-50"
          >
            {uploading ? <Loader2 size={12} className="animate-spin" /> : null}
            {uploading ? 'Yuklanmoqda...' : 'Rasm yuklash'}
          </button>
          {value && (
            <button
              type="button"
              onClick={() => onChange(null)}
              disabled={disabled}
              className="text-xs text-[#E24B4A] hover:underline text-left disabled:opacity-50"
            >
              Rasmni o'chirish
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
