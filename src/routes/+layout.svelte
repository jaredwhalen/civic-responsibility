<script>
	import { base } from '$app/paths';
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { beforeNavigate, afterNavigate } from '$app/navigation';
	import { fade } from 'svelte/transition';
	import Header from '$lib/components/Header.svelte';

	import '$lib/fonts/stylesheet.css';
	import '$lib/styles/global.scss';
	import copy from '$lib/data/copy.json';
	let headerHeight = $state(0);

	import { page, navigating } from '$app/stores';

	const { meta } = copy;

	// Track navigation state for loading overlay
	let showOverlay = $state(false);
	let navigationTimeout;
	let minDisplayTime = 500; // Minimum time to show overlay (ms)
	let navigationStartTime = 0;

	// Use SvelteKit's navigating store combined with manual tracking
	$effect(() => {
		if (!browser) return;

		const nav = $navigating;

		if (nav) {
			// Navigation started
			if (!showOverlay) {
				showOverlay = true;
				navigationStartTime = Date.now();
			}

			// Clear any existing timeout
			if (navigationTimeout) {
				clearTimeout(navigationTimeout);
			}

			// Set a fallback timeout
			navigationTimeout = setTimeout(() => {
				showOverlay = false;
				navigationStartTime = 0;
			}, 5000);
		} else if (showOverlay && navigationStartTime > 0) {
			// Navigation completed - ensure minimum display time
			if (navigationTimeout) {
				clearTimeout(navigationTimeout);
				navigationTimeout = null;
			}

			const elapsed = Date.now() - navigationStartTime;
			const remainingTime = Math.max(0, minDisplayTime - elapsed);

			setTimeout(() => {
				showOverlay = false;
				navigationStartTime = 0;
			}, remainingTime);
		}
	});

	// Listen to beforeNavigate for immediate response
	beforeNavigate(({ to, from }) => {
		if (!browser) return;

		if (to && from && to.url.pathname !== from.url.pathname) {
			showOverlay = true;
			navigationStartTime = Date.now();
		}
	});

	// Determine page-specific title based on route
	let pageTitle = $derived.by(() => {
		const route = $page.route.id;
		if (route === '/quiz') {
			return `Quiz | ${meta.title}`;
		} else if (route === '/dashboard') {
			return `Data | ${meta.title}`;
		}
		return meta.title;
	});

	let pageDescription = meta.description;
</script>

<svelte:head>
	<title>{pageTitle}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
	<meta
		name="description"
		content={pageDescription || 'Interactive civic responsibility exploration'}
	/>

	<!-- Open Graph / Facebook -->
	<meta property="og:type" content="website" />
	<meta property="og:title" content={pageTitle} />
	<meta property="og:description" content={pageDescription} />
	<meta property="og:url" content="http://civicprofile.us{$page.url.pathname}" />
	<meta property="og:site_name" content="Civic Responsibility" />
	<meta property="og:image" content="http://civicprofile.us/og-image.jpg" />
	<meta property="og:image:width" content="1200" />
	<meta property="og:image:height" content="630" />
	<meta property="og:image:alt" content={meta.title} />

	<!-- Twitter -->
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:title" content={pageTitle} />
	<meta name="twitter:description" content={pageDescription} />
	<meta name="twitter:image" content="http://civicprofile.us/og-image.jpg" />
	<meta name="twitter:image:alt" content={meta.title} />

	<!-- Additional Meta Tags -->
	<meta name="author" content="Beacon Project" />
	<meta name="theme-color" content="#ffffff" />

	<!-- Canonical URL -->
	<link rel="canonical" href="http://civicprofile.us{$page.url.pathname}" />

	<!-- Google tag (gtag.js) -->
	<script async src="https://www.googletagmanager.com/gtag/js?id=G-SPS5VG2ZGN"></script>
	<script>
		window.dataLayer = window.dataLayer || [];
		function gtag() {
			dataLayer.push(arguments);
		}
		gtag('js', new Date());
		gtag('config', 'G-SPS5VG2ZGN');
	</script>
</svelte:head>

<main
	role="main"
	aria-label="Civic Responsibility in America"
	style:--header-height="{headerHeight}px"
>
	<Header bind:headerHeight mode={$page.route.id === '/' ? 'main' : 'route'} />

	<slot />

	{#if showOverlay}
		<div class="navigation-overlay" role="status" aria-label="Loading" out:fade={{ duration: 200 }}>
			<div class="spinner"></div>
		</div>
	{/if}
</main>

<style lang="scss">
	@import '$lib/styles/mixins.scss';

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

	.navigation-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: var(--color-theme-light);
		background: #ffffff;
		z-index: 1000;
		display: flex;
		align-items: center;
		justify-content: center;
		opacity: 1;
		transition: opacity 0.2s ease;
		pointer-events: all;
		will-change: opacity;

		.spinner {
			width: 50px;
			height: 50px;
			border: 4px solid #f3f3f3;
			border-top: 4px solid var(--color-theme-blue);
			border-radius: 50%;
			animation: spin 1s linear infinite;
		}
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}
</style>
