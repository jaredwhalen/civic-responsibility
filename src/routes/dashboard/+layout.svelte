<script>
	import { base } from '$app/paths';
	import Footer from '$lib/components/Footer.svelte';
	import '$lib/fonts/stylesheet.css';
	import '$lib/styles/global.scss';
	import copy from '$lib/data/copy.json';

	let headerHeight = $state(80);

	const { meta } = copy;
</script>

<svelte:head>
	<title>{meta.title}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
	<meta
		name="description"
		content={meta.description || 'Interactive civic responsibility exploration'}
	/>
</svelte:head>

<main
	role="main"
	aria-label="Civic Responsibility Interactive Experience"
	style:--header-height="{headerHeight}px"
>
	<header
		class="main-header"
		role="banner"
		aria-label="Site navigation"
		bind:clientHeight={headerHeight}
	>
		<div class="header-right">
			<img
				class="logo"
				src={base + '/assets/icons/Lockup_WhiteWhite.png'}
				alt="More in Common"
				role="img"
				aria-label="More in Common logo"
			/>
		</div>
	</header>

	<slot />
</main>

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	.main-header {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: $spacing-sm $spacing-lg;
		z-index: 2000;
		pointer-events: none;

		height: 80px;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			height: 60px;
			padding: $spacing-xs $spacing-md;
		}

		@include mq('small-mobile', 'max') {
			height: 50px;
			padding: $spacing-xs $spacing-sm;
		}

		.header-left,
		.header-right {
			pointer-events: auto;

			.logo {
				height: auto;
				width: 100%;
				max-width: 300px;

				// Mobile responsive logo sizing
				@include mq('mobile', 'max') {
					max-width: 200px;
				}

				@include mq('small-mobile', 'max') {
					max-width: 150px;
				}
			}
		}
		.header-left {
			display: flex;
			align-items: center;
		}
		.hamburger {
			background: none;
			border: none;
			padding: 0;
			width: 36px;
			height: 36px;
			display: flex;
			flex-direction: column;
			justify-content: center;
			gap: 6px;
			cursor: pointer;
			span {
				display: block;
				height: 4px;
				width: 100%;
				background: #fff;
				border-radius: 2px;
			}
		}
		.header-right {
			display: flex;
			gap: $spacing-lg;
			height: -webkit-fill-available;
			.logo {
				color: #fff;
				font-weight: 700;
				font-size: 1.1rem;
				text-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
				&.logo-mic {
					letter-spacing: 0.02em;
				}
				&.logo-beacon {
					font-family: serif;
					letter-spacing: 0.08em;
				}
			}
		}
	}

	:global {
		body {
			background: var(--bg-color);
		}

		.background-container {
			z-index: 0;
			position: relative;

			transition: background-color 0.75s ease;

			&[data-theme='default'] {
				background: linear-gradient(135deg, var(--bg-color), #fff);
				background: var(--bg-color);
			}
			&[data-theme='light'] {
				// background: linear-gradient(135deg, var(--bg-color), #fff);
				background: var(--bg-color);
				// background: linear-gradient(135deg, var(--color-theme-blue), #111);
			}
			&[data-theme='dark'] {
				background-color: $color-theme-dark;
			}
		}

		.foreground-container {
			transition:
				color 0.75s ease,
				background-color 0.75s ease,
				opacity 0.5s ease;

			&[data-theme='default'] {
				color: #000;
				.slide-inner p {
					// background: $color-theme-light;
				}
			}
			&[data-theme='dark'] {
				// color: $color-beacon-white;
				.slide-inner p {
					// background: $color-beacon-dark-green;
				}
			}

			&[data-theme='green'] {
				// $color-beacon-light-green: #64B42D;
				// $color-beacon-dark-green: #233219;
				background: $color-theme-transition;
				// color: $color-beacon-white;
				.slide-inner p {
					// background: $color-beacon-dark-green;
				}
			}

			&[data-theme='blue'] {
				background: var(--bg-color);
				// background: linear-gradient(135deg, var(--color-theme-blue), #111);
				.slide-inner p {
					// background: $color-theme-light;
				}
			}

			&.interactive-mode {
				opacity: 0;
			}
		}

		svelte-scroller-foreground {
			pointer-events: none;
		}

		svelte-scroller-background-container.interactive {
			pointer-events: all;
		}
	}
</style>
