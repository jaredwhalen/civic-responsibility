# Global SASS Setup

This project uses a modern approach to global SASS variables and mixins in SvelteKit.

## Configuration

The global SASS variables and mixins are automatically available in all `.scss` files and Svelte components with `<style lang="scss">` without needing manual imports.

### Files Structure

- `src/lib/styles/variables.scss` - Global SASS variables
- `src/lib/styles/mixins.scss` - Global SASS mixins  
- `src/lib/styles/global.scss` - Global styles (compiled to `static/global.css`)

### How It Works

1. **Vite Configuration** (`vite.config.js`): Automatically injects variables and mixins into all SASS files
2. **Svelte Configuration** (`svelte.config.js`): Ensures proper preprocessing
3. **No Manual Imports**: Components can use variables and mixins directly

## Usage

### In Svelte Components

```scss
<style lang="scss">
.my-component {
  // Variables are available globally
  color: $primary-color;
  padding: $spacing-md;
  
  // Mixins are available globally
  @include respond-to(md) {
    font-size: $font-size-lg;
  }
  
  @include button-base;
}
</style>
```

### In SCSS Files

```scss
// No imports needed - variables and mixins are global
.custom-class {
  background: $secondary-color;
  @include card-style;
}
```

## Available Variables

### Colors
- `$primary-color`, `$secondary-color`, `$accent-color`
- `$success-color`, `$warning-color`, `$error-color`
- `$text-color`, `$text-light`, `$background-color`, `$border-color`

### Typography
- `$font-family-primary`, `$font-family-mono`
- `$font-size-xs` through `$font-size-4xl`

### Spacing
- `$spacing-xs` through `$spacing-2xl`

### Breakpoints
- `$breakpoint-sm`, `$breakpoint-md`, `$breakpoint-lg`, `$breakpoint-xl`, `$breakpoint-2xl`

## Available Mixins

### Responsive
- `@include respond-to(sm|md|lg|xl|2xl)`

### Components
- `@include button-base`
- `@include card-style`

### Layout
- `@include flex-center`
- `@include flex-between`
- `@include flex-column`
- `@include grid($columns, $gap)`
- `@include grid-responsive($min-width)`

### Utilities
- `@include text-truncate`
- `@include text-gradient($color1, $color2)`
- `@include input-base`
- `@include sr-only`

### Animations
- `@include fade-in($duration)`
- `@include slide-up($duration)`

## Benefits

1. **No Manual Imports**: Variables and mixins are available everywhere
2. **Better Performance**: No duplicate imports across components
3. **Easier Maintenance**: Single source of truth for design tokens
4. **Modern Convention**: Follows current SvelteKit best practices
5. **Type Safety**: Better IDE support and autocomplete

## Migration Notes

- Removed all `@import '$lib/styles/variables.scss'` and `@import '$lib/styles/mixins.scss'` from components
- Variables and mixins are now globally available
- No changes needed to existing component styles - they just work 