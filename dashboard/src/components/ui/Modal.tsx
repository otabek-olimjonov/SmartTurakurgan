import { type ReactNode, useEffect, useRef } from 'react'
import { X } from 'lucide-react'
import { cn } from '../../lib/utils'

interface ModalProps {
  open: boolean
  title: string
  onClose: () => void
  children: ReactNode
  size?: 'md' | 'lg'
}

export default function Modal({ open, title, onClose, children, size = 'md' }: ModalProps) {
  const dialogRef = useRef<HTMLDialogElement>(null)

  useEffect(() => {
    const el = dialogRef.current
    if (!el) return
    if (open) el.showModal()
    else el.close()
  }, [open])

  return (
    <dialog
      ref={dialogRef}
      onCancel={onClose}
      className={cn(
        'rounded-xl border border-[#E8E6E1] bg-white p-0 shadow-lg backdrop:bg-black/30 m-auto',
        size === 'md' ? 'w-full max-w-md' : 'w-full max-w-2xl',
      )}
    >
      <div className="flex items-center justify-between px-5 py-4 border-b border-[#E8E6E1]">
        <h2 className="text-sm font-medium text-[#0A0A0A]">{title}</h2>
        <button
          onClick={onClose}
          className="text-[#888780] hover:text-[#0A0A0A] transition-colors"
        >
          <X size={16} />
        </button>
      </div>
      <div className="px-5 py-4">{children}</div>
    </dialog>
  )
}
