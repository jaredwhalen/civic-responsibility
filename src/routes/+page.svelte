<script>
	import { base } from '$app/paths';
	import { goto } from '$app/navigation';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import DebugPanel from '$lib/components/DebugPanel.svelte';
	import copy from '$lib/data/copy.json';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import GSAPScroller from '$lib/components/scroller/Scroller.svelte';
	import Scroller from '$lib/components/scrolly/_Scroller.svelte';
	import Background from '$lib/components/scrolly/Background.svelte';
	import Slide from '$lib/components/scrolly/Slide.svelte';
	import TextFooter from '$lib/components/scrolly/TextFooter.svelte';
	import CTA from '$lib/components/CTA.svelte';
	import Dashboard from '$lib/components/dashboard/Dashboard.svelte';
	import Quiz from '$lib/components/quiz/Quiz.svelte';
	const { meta, content } = copy;

	let count2 = $state(0);
	let index2 = $state(0);
	let offset2 = $state(0);
	let progress2 = $state(0);
	let top2 = 0;
	let threshold2 = 0.25;
	let bottom2 = 1;

	let interactiveMode = $state(false);

	let showQuiz = $state(false);

	// Derived variables for each Scrolly component

	const activeSlide2 = $derived(content.scrolly.slidesFixed[index2]);
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

<Scroller
	top={top2}
	threshold={threshold2}
	bottom={bottom2}
	bind:count={count2}
	bind:index={index2}
	bind:offset={offset2}
	bind:progress={progress2}
	interactiveBg={Boolean(activeSlide2.interactiveBg)}
	role="region"
	aria-label="Second interactive content scroll area"
>
	{#snippet background()}
		<div
			class="background-container"
			data-theme={activeSlide2.theme || 'default'}
			role="presentation"
			aria-hidden="true"
		>
			<Background
				count={count2}
				index={index2}
				offset={offset2}
				progress={progress2}
				activeId={activeSlide2.id}
				showDashboard={Boolean(activeSlide2.showDashboard)}
				{interactiveMode}
			/>
		</div>

		<TextFooter content={activeSlide2} />
	{/snippet}

	{#snippet foreground()}
		<div
			class="foreground-container {interactiveMode ? 'interactive-mode' : ''}"
			data-theme={activeSlide2.theme || 'default'}
			role="main"
			aria-label="Second content slides"
		>
			{#each content.scrolly.slidesFixed as slide, slideIndex}
				<Slide
					content={slide}
					cls="slide-{slideIndex} {slide.cls}"
					index={slideIndex}
					bind:interactiveMode
					aria-label="Slide {slideIndex + 1} of {content.scrolly.slidesFixed.length}"
					noText={slide.noFgText}
				/>
			{/each}
		</div>
	{/snippet}
</Scroller>

<GSAPScroller section="outro" />

<CTA bind:showQuiz />

<div class="dashboard-preview">
	<div class="overlay" transition:fade={{ duration: 500 }}>
		<button class="explore-button" onclick={() => window.location.href = '/dashboard'}>Explore the data</button>
	</div>
	<Dashboard activeId="9999-dashboard" interactiveMode={true} />
</div>
{#if showQuiz}
	<Quiz bind:showQuiz />
{/if}

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	// Accessibility utilities
	.visually-hidden {
		position: absolute !important;
		width: 1px !important;
		height: 1px !important;
		padding: 0 !important;
		margin: -1px !important;
		overflow: hidden !important;
		clip: rect(0, 0, 0, 0) !important;
		white-space: nowrap !important;
		border: 0 !important;
	}


	.dashboard-preview {
		position: relative;
		width: 100%;
		height: 100%;
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
