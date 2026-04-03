import { forwardRef, type ButtonHTMLAttributes } from 'react'
import { cn } from '../../lib/utils'

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost'
type Size = 'sm' | 'md'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
  size?: Size
  loading?: boolean
}

const VARIANTS: Record<Variant, string> = {
  primary: 'bg-[#1D9E75] text-white hover:bg-[#178a64] border-transparent',
  secondary: 'bg-white text-[#0A0A0A] border-[#E8E6E1] hover:bg-[#F7F6F3]',
  danger: 'bg-[#E24B4A] text-white hover:bg-[#c83e3d] border-transparent',
  ghost: 'bg-transparent text-[#888780] border-transparent hover:text-[#0A0A0A]',
}

const SIZES: Record<Size, string> = {
  sm: 'px-3 py-1.5 text-xs',
  md: 'px-4 py-2 text-sm',
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'secondary', size = 'md', loading, disabled, className, children, ...props }, ref) => (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={cn(
        'inline-flex items-center gap-1.5 rounded-lg border font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
        VARIANTS[variant],
        SIZES[size],
        className,
      )}
      {...props}
    >
      {loading && (
        <span className="w-3 h-3 border-2 border-current border-r-transparent rounded-full animate-spin" />
      )}
      {children}
    </button>
  ),
)
Button.displayName = 'Button'

export default Button
