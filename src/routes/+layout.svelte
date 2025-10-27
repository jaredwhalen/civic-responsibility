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
