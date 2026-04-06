import { useRef, useState } from 'react'
import { Star, X, Plus, Loader2 } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { cn } from '../../lib/utils'

export type ManagedImage = {
  url: string
  is_main: boolean
}

interface Props {
  value: ManagedImage[]
  onChange: (images: ManagedImage[]) => void
  folder: string
  maxImages?: number
  disabled?: boolean
}

export default function ImageUploader({ value, onChange, folder, maxImages = 10, disabled }: Props) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [uploading, setUploading] = useState(false)

  async function handleFiles(files: FileList | null) {
    if (!files || files.length === 0) return
    setUploading(true)
    const results: ManagedImage[] = []
    try {
      for (const file of Array.from(files)) {
        const ext = file.name.split('.').pop()?.toLowerCase() ?? 'jpg'
        const path = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
        const { error } = await supabase.storage.from('images').upload(path, file, {
          cacheControl: '3600',
          upsert: false,
        })
        if (error) {
          console.error('[ImageUploader] upload error:', error.message)
          continue
        }
        const { data: { publicUrl } } = supabase.storage.from('images').getPublicUrl(path)
        results.push({ url: publicUrl, is_main: false })
      }
    } finally {
      setUploading(false)
    }
    if (results.length === 0) return
    const merged = [...value, ...results].slice(0, maxImages)
    const hasMain = merged.some(img => img.is_main)
    onChange(hasMain ? merged : merged.map((img, i) => ({ ...img, is_main: i === 0 })))
  }

  function setMain(index: number) {
    onChange(value.map((img, i) => ({ ...img, is_main: i === index })))
  }

  function remove(index: number) {
    const updated = value.filter((_, i) => i !== index)
    if (updated.length > 0 && !updated.some(img => img.is_main)) {
      updated[0] = { ...updated[0], is_main: true }
    }
    onChange(updated)
  }

  return (
    <div className="flex flex-col gap-2">
      <label className="text-xs font-medium text-[#0A0A0A]">Rasmlar</label>
      <div className="grid grid-cols-4 gap-2">
        {value.map((img, i) => (
          <div
            key={`${img.url}-${i}`}
            className="relative group aspect-square rounded-lg overflow-hidden border border-[#E8E6E1] bg-[#F7F6F3]"
          >
            <img src={img.url} alt="" className="w-full h-full object-cover" />

            {/* Set as main — star icon top-left */}
            <button
              type="button"
              disabled={disabled || img.is_main}
              onClick={() => setMain(i)}
              title={img.is_main ? 'Asosiy rasm' : 'Asosiy rasm sifatida belgilash'}
              className={cn(
                'absolute top-1 left-1 w-6 h-6 rounded-full flex items-center justify-center transition-all shadow-sm',
                img.is_main
                  ? 'bg-[#1D9E75] text-white cursor-default'
                  : 'bg-black/50 text-white hover:bg-[#1D9E75] opacity-0 group-hover:opacity-100',
              )}
            >
              <Star size={10} fill={img.is_main ? 'currentColor' : 'none'} />
            </button>

            {/* Remove — X icon top-right */}
            <button
              type="button"
              disabled={disabled}
              onClick={() => remove(i)}
              className="absolute top-1 right-1 w-6 h-6 rounded-full bg-black/50 text-white flex items-center justify-center hover:bg-[#E24B4A] opacity-0 group-hover:opacity-100 transition-all shadow-sm"
            >
              <X size={10} />
            </button>

            {/* Main badge — bottom strip */}
            {img.is_main && (
              <div className="absolute bottom-0 left-0 right-0 bg-[#1D9E75]/90 text-white text-[9px] text-center py-0.5 font-medium tracking-wide">
                ASOSIY
              </div>
            )}
          </div>
        ))}

        {/* Upload button */}
        {value.length < maxImages && (
          <button
            type="button"
            disabled={disabled || uploading}
            onClick={() => inputRef.current?.click()}
            className="aspect-square rounded-lg border-2 border-dashed border-[#E8E6E1] flex flex-col items-center justify-center gap-1.5 text-[#888780] hover:border-[#1D9E75] hover:text-[#1D9E75] transition-colors disabled:opacity-50 cursor-pointer"
          >
            {uploading
              ? <Loader2 size={18} className="animate-spin" />
              : <Plus size={18} />
            }
            <span className="text-[10px] font-medium">
              {uploading ? 'Yuklanmoqda...' : "Rasm qo'shish"}
            </span>
          </button>
        )}
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png,image/webp,image/gif"
        multiple
        className="hidden"
        onChange={(e) => { handleFiles(e.target.files); e.target.value = '' }}
      />
    </div>
  )
}
