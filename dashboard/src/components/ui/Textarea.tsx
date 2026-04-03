import { forwardRef, type TextareaHTMLAttributes } from 'react'
import { cn } from '../../lib/utils'

interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string
  error?: string
}

const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ label, error, className, id, ...props }, ref) => {
    const inputId = id ?? label?.toLowerCase().replace(/\s+/g, '-')
    return (
      <div className="flex flex-col gap-1">
        {label && (
          <label htmlFor={inputId} className="text-xs font-medium text-[#0A0A0A]">
            {label}
          </label>
        )}
        <textarea
          ref={ref}
          id={inputId}
          rows={4}
          className={cn(
            'w-full rounded-lg border bg-white px-3 py-2 text-sm text-[#0A0A0A] placeholder:text-[#888780] outline-none resize-y transition-colors',
            error
              ? 'border-[#E24B4A] focus:border-[#E24B4A]'
              : 'border-[#E8E6E1] focus:border-[#1D9E75]',
            className,
          )}
          {...props}
        />
        {error && <p className="text-xs text-[#E24B4A]">{error}</p>}
      </div>
    )
  },
)
Textarea.displayName = 'Textarea'

export default Textarea
