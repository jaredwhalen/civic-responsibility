<script>
	import { base } from '$app/paths';
	import { page } from '$app/stores';
	import { goto, afterNavigate } from '$app/navigation';
	import { browser } from '$app/environment';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';

	import copy from '$lib/data/copy.json';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import { userResponse } from '$lib/stores/userResponse.js';

	import GSAPScroller from '$lib/components/GSAPScroller/GSAPScroller.svelte';
	import MatrixScroller from '$lib/components/MatrixScroller/MatrixScroller.svelte';

	import Explore from '$lib/components/Explore.svelte';
	import EmailSignupSection from '$lib/components/EmailSignupSection.svelte';
	import Dashboard from '$lib/components/dashboard/Dashboard.svelte';
	import Quiz from '$lib/components/quiz/Quiz.svelte';
	const { meta, content } = copy;

	let showEndItems = $state(false);
	let scrollListenerAdded = $state(false);

	// Derive if we're on the home page - reactive like Header does
	let isHomePage = $derived($page.route.id === '/');

	// Check if user has scrolled to bottom of page
	function checkScrollToBottom() {
		if (!browser) return;

		const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
		const scrollHeight = document.documentElement.scrollHeight;
		const clientHeight = window.innerHeight;

		// Check if user is at bottom (with small tolerance)
		const isAtBottom = scrollTop + clientHeight >= scrollHeight - 10;

		if (isAtBottom && !showEndItems && $userResponse.submitted) {
			// Wait 1 second then show footer
			setTimeout(() => {
				showEndItems = true;
			}, 500);
		}
	}

	function initializePage() {
		if (!browser) return;

		const fromExplore = $page.url.href.includes('?fromExplore=true');

		if (fromExplore) {
			$userResponse.submitted = true;
			showEndItems = true;

			setTimeout(() => {
				const exploreElement = document.getElementById('explore');
				if (exploreElement) {
					exploreElement.scrollIntoView();
				}
				// Remove fromExplore parameter from URL
				const url = new URL(window.location.href);
				url.searchParams.delete('fromExplore');
				window.history.replaceState({}, '', url.pathname + url.search + url.hash);
			}, 0);
		}

		// Check initial scroll position in case user is already at bottom
		setTimeout(() => {
			checkScrollToBottom();
		}, 100);
	}

	function setupScrollListener() {
		if (!browser || scrollListenerAdded) return;

		window.addEventListener('scroll', checkScrollToBottom);
		scrollListenerAdded = true;
	}

	function removeScrollListener() {
		if (!browser || !scrollListenerAdded) return;

		window.removeEventListener('scroll', checkScrollToBottom);
		scrollListenerAdded = false;
	}

	onMount(() => {
		initializePage();
		setupScrollListener();

		// Cleanup
		return () => {
			removeScrollListener();
		};
	});

	// React to route changes reactively - similar to how Header does it
	$effect(() => {
		if (!browser) return;

		const routeId = $page.route.id;
		const pathname = $page.url.pathname;

		if (routeId === '/') {
			// Re-initialize when coming back to home page
			setTimeout(() => {
				initializePage();
				setupScrollListener();
			}, 0);
		} else {
			// Remove listener when navigating away from home
			removeScrollListener();
		}
	});

	// Handle navigation (including browser back button) - keep for immediate updates
	afterNavigate(({ to }) => {
		if (!browser) return;
		// Only initialize if navigating to the home page
		if (to?.route.id === '/') {
			setTimeout(() => {
				initializePage();
				setupScrollListener();
			}, 10);
		} else {
			// Remove listener when navigating away
			removeScrollListener();
		}
	});
</script>

<svelte:head>
	<title>{meta.title}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
	<meta
		name="description"
		content={meta.description || 'Interactive civic responsibility exploration'}
	/>
</svelte:head>

<Hero
	videoSrc={content.hero.video || '/assets/videos/web-bg.mp4'}
	poster={content.hero.poster || '/assets/videos/placeholder.jpg'}
	heroText={content.hero.text}
/>

<GSAPScroller section="intro" />

<MatrixScroller {content} />

{#if $userResponse.submitted}
	<GSAPScroller section="outro" />

	<Explore />

	{#if showEndItems}
		<EmailSignupSection />
		<Footer />
	{/if}
{/if}

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	.dashboard-preview {
		position: relative;
		width: 100%;
		height: 60vh;
		overflow: hidden;
		display: flex;
		justify-content: center;
		align-items: center;
	}

	// Overlay for interactive mode
	.overlay {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: 10000;
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: 2rem;

		&::before {
			content: '';
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			background: linear-gradient(
				135deg,
				var(--color-theme-blue) 0%,
				var(--color-theme-blue-light) 100%
			);
			opacity: 0.75;
		}

		.explore-button {
			background-color: transparent;
			border: 3px solid white;
			color: white;
			z-index: 20000;
			font-size: 2rem;
			font-weight: 600;
			padding: 1.5rem 3rem;
			border-radius: 12px;
			transition: all 0.3s ease;
			cursor: pointer;
			letter-spacing: 1px;

			&:hover {
				transform: scale(1.05);
				background-color: white;
				color: var(--color-theme-blue);
			}
		}

		.overlay-text {
			z-index: 20000;
			color: white;
			text-align: center;
			max-width: 600px;

			h3 {
				font-size: 2.5rem;
				font-weight: 700;
				margin: 0 0 1rem 0;
				text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
			}

			p {
				font-size: 1.2rem;
				margin: 0;
				opacity: 0.9;
				line-height: 1.6;
			}
		}
	}
</style>
