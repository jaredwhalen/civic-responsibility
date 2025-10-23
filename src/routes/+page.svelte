<script>
	import { base } from '$app/paths';
	import { goto } from '$app/navigation';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';

	import copy from '$lib/data/copy.json';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import { userResponse } from '$lib/stores/userResponse.js';

	import GSAPScroller from '$lib/components/GSAPScroller/GSAPScroller.svelte';
	import MatrixScroller from '$lib/components/MatrixScroller/MatrixScroller.svelte';

	import CTA from '$lib/components/CTA.svelte';
	import EmailSignupSection from '$lib/components/EmailSignupSection.svelte';
	import Dashboard from '$lib/components/dashboard/Dashboard.svelte';
	import Quiz from '$lib/components/quiz/Quiz.svelte';
	const { meta, content } = copy;
	

	let showFooter = $state(false);

	// Check if user has scrolled to bottom of page
	function checkScrollToBottom() {
		const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
		const scrollHeight = document.documentElement.scrollHeight;
		const clientHeight = window.innerHeight;

		// Check if user is at bottom (with small tolerance)
		const isAtBottom = scrollTop + clientHeight >= scrollHeight - 10;

		if (isAtBottom && !showFooter && $userResponse.submitted) {
			// Wait 1 second then show footer
			setTimeout(() => {
				showFooter = true;
			}, 500);
		}
	}

	onMount(() => {
		// Check initial scroll position in case user is already at bottom
		checkScrollToBottom();

		// Add scroll listener
		window.addEventListener('scroll', checkScrollToBottom);

		// Cleanup
		return () => {
			window.removeEventListener('scroll', checkScrollToBottom);
		};
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

	<EmailSignupSection />

	<CTA />

	{#if showFooter}
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
