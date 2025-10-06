<script>
	import { base } from '$app/paths';
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
	import Dashboard from '$lib/components/scrolly/dashboard/Dashboard.svelte';
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

<main role="main" aria-label="Civic Responsibility Interactive Experience">
	<header class="main-header" role="banner" aria-label="Site navigation">
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

	<Dashboard activeId="9999-dashboard" interactiveMode={true} />
	{#if showQuiz}
		<Quiz bind:showQuiz />
	{/if}

	<Footer />
</main>

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
		// background: linear-gradient(to bottom, rgba(#000000, 0.5) 0%, rgba(#000000, 0.25) 50%, rgba(247, 243, 238, 0) 90%);

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
