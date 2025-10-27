<script>
	import { base } from '$app/paths';
	import { onMount } from 'svelte';
	import Header from '$lib/components/Header.svelte';

	import '$lib/fonts/stylesheet.css';
	import '$lib/styles/global.scss';
	import copy from '$lib/data/copy.json';
	let headerHeight = $state(0);

	import { page } from '$app/stores';

	const { meta } = copy;
	
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
	

	let pageDescription = meta.description

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
	<meta property="og:url" content="https://civicresponsibility.org{$page.url.pathname}" />
	<meta property="og:site_name" content="Civic Responsibility" />
	<meta property="og:image" content="https://civicresponsibility.org/og-image.jpg" />
	<meta property="og:image:width" content="1200" />
	<meta property="og:image:height" content="630" />
	<meta property="og:image:alt" content={meta.title} />
	
	<!-- Twitter -->
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:title" content={pageTitle} />
	<meta name="twitter:description" content={pageDescription} />
	<meta name="twitter:image" content="https://civicresponsibility.org/og-image.jpg" />
	<meta name="twitter:image:alt" content={meta.title} />
	
	<!-- Additional Meta Tags -->
	<meta name="author" content="Beacon" />
	<meta name="theme-color" content="#ffffff" />
	
	<!-- Canonical URL -->
	<link rel="canonical" href="https://civicresponsibility.org{$page.url.pathname}" />
</svelte:head>

<main
	role="main"
	aria-label="Civic Responsibility Interactive Experience"
	style:--header-height="{headerHeight}px"
>
	<Header bind:headerHeight mode={$page.route.id === '/' ? 'main' : 'route'}/>

	<slot />
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
</style>
