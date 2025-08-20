<script>
	import { base } from '$app/paths';
	import Scroller from '$lib/components/scrolly/_Scroller.svelte';
	import Background from '$lib/components/scrolly/Background.svelte';
	import Slide from '$lib/components/scrolly/Slide.svelte';
	import Dashboard from '$lib/components/scrolly/dashboard/Dashboard.svelte';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import DebugPanel from '$lib/components/DebugPanel.svelte';
	import copy from '$lib/data/copy.json';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';

	const { meta, content } = copy;

	let count = $state(0);
	let index = $state(0);
	let offset = $state(0);
	let progress = $state(0);
	let top = 0;
	let threshold = 0.25;
	let bottom = 1;

	// content.scrolly.slides.push({id: '9999-dashboard', cls: 'dashboard-faux', showDashboard: true, interactiveBg: true})

	const activeSlide = $derived(content.scrolly.slides[index]);

	let interactiveMode = $state(false);
	let shouldShowOverlay = $state(false);
	let showExpandedModal = $state(false);

	// Show overlay when dashboard appears
	$effect(() => {
		if (interactiveMode) {
			shouldShowOverlay = true;
			// Small delay to ensure DOM is ready before shrinking modal
			setTimeout(() => {
				showExpandedModal = true;
			}, 250);
		} else {
			showExpandedModal = false;
			// Delay hiding the overlay to allow exit animation to complete
			setTimeout(() => {
				shouldShowOverlay = false;
			}, 250); // Match the CSS transition duration
		}
	});

	// Handle escape key to close dashboard
	onMount(() => {
		const handleKeydown = (event) => {
			if (event.key === 'Escape' && interactiveMode) {
				interactiveMode = false;
			}
		};

		document.addEventListener('keydown', handleKeydown);
		return () => document.removeEventListener('keydown', handleKeydown);
	});
</script>

<svelte:head>
	<title>{meta.title}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
	<meta name="description" content={meta.description || 'Interactive civic responsibility exploration'}>
</svelte:head>

<main style:--bg-color={'#d1dfed'} role="main" aria-label="Civic Responsibility Interactive Experience">
	<header class="main-header" role="banner" aria-label="Site navigation">
		<div class="header-left">
			<!-- <button class="hamburger" aria-label="Open menu" aria-expanded="false" aria-controls="main-menu">
				<span></span><span></span><span></span>
			</button> -->
		</div>
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

	<!-- Debug Panel -->
	<!-- <DebugPanel {count} {index} {offset} {progress} /> -->

	{#if shouldShowOverlay}
		<div 
			class="dashboard-overlay" 
			transition:fade={{ duration: 250 }}
			role="dialog"
			aria-modal="true"
			aria-labelledby="dashboard-title"
			aria-describedby="dashboard-description"
		>
			<div class="dashboard-overlay-content {showExpandedModal ? 'expanded' : ''} {$isMobile ? 'mobile' : ''} {$isTablet ? 'tablet' : ''}">
				<div class="dashboard-header">
					<h2 id="dashboard-title" class="visually-hidden">Interactive Dashboard</h2>
					<p id="dashboard-description" class="visually-hidden">Explore civic responsibility data and insights</p>
					<!-- <button 
						class="close-button"
						onclick={() => interactiveMode = false}
						aria-label="Close dashboard"
						type="button"
					>
						<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<line x1="18" y1="6" x2="6" y2="18"></line>
							<line x1="6" y1="6" x2="18" y2="18"></line>
						</svg>
					</button> -->
				</div>
				<Dashboard activeId="9999-dashboard" bind:interactiveMode animateMount={false} />
			</div>
		</div>
	{/if}
	
	<Scroller
		{top}
		{threshold}
		{bottom}
		bind:count
		bind:index
		bind:offset
		bind:progress
		interactiveBg={Boolean(activeSlide.interactiveBg)}
		role="region"
		aria-label="Interactive content scroll area"
	>
		{#snippet background()}
			<div 
				class="background-container" 
				data-theme={activeSlide.theme || 'default'}
				role="presentation"
				aria-hidden="true"
			>
				<Background
					{count}
					{index}
					{offset}
					{progress}
					activeId={activeSlide.id}
					showDashboard={Boolean(activeSlide.showDashboard)}
					{interactiveMode}
				/>
			</div>
		{/snippet}

		{#snippet foreground()}
			<div
				class="foreground-container {interactiveMode ? 'interactive-mode' : ''}"
				data-theme={activeSlide.theme || 'default'}
				role="main"
				aria-label="Content slides"
			>
				{#each content.scrolly.slides as slide, slideIndex}
					<Slide 
						content={slide} 
						cls="slide-{slideIndex} {slide.cls}" 
						index={slideIndex} 
						bind:interactiveMode 
						aria-label="Slide {slideIndex + 1} of {content.scrolly.slides.length}"
					/>
				{/each}
			</div>
		{/snippet}
	</Scroller>

	<Footer />
</main>

<style lang="scss">
	@import '$lib/styles/mixins.scss';
	
	:global {
		body {
			background: #f7f3ee;
		}

		.background-container {
			z-index: 0;
			position: relative;

			transition: background-color 0.75s ease;

			&[data-theme='default'] {
				background: $color-theme-light;
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

	.dashboard-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		width: 100vw;
		height: 100vh;
		z-index: 9999;
		background: $color-theme-blue;
		box-sizing: border-box;
		padding: 0px;

		transition: all 0.5s ease;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding: 0;
		}

		.dashboard-overlay-content {
			width: 100%;
			height: 100%;
			background: $color-theme-light;
			border-radius: 4px;
			box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
			overflow: hidden;
			transition: all 0.5s ease;
			position: relative;

			&.expanded {
				width: calc(100% - 30px);
				height: calc(100% - 30px);
				margin: 15px;
				overflow: hidden;

				// Mobile responsive expanded state
				@include mq('mobile', 'max') {
					width: calc(100% - 20px);
					height: calc(100% - 20px);
					margin: 10px;
				}

				@include mq('small-mobile', 'max') {
					width: calc(100% - 10px);
					height: calc(100% - 10px);
					margin: 5px;
				}
			}

			// Mobile specific styles
			&.mobile {
				border-radius: 0;
				
				&.expanded {
					border-radius: 8px;
				}
			}

			&.tablet {
				&.expanded {
					border-radius: 12px;
				}
			}
		}

		.dashboard-header {
			position: absolute;
			top: 0;
			right: 0;
			z-index: 10000;
			padding: $spacing-md;
			display: flex;
			justify-content: flex-end;

			@include mq('mobile', 'max') {
				padding: $spacing-sm;
			}
		}

		.close-button {
			background: rgba(255, 255, 255, 0.9);
			border: none;
			border-radius: 50%;
			width: 40px;
			height: 40px;
			display: flex;
			align-items: center;
			justify-content: center;
			cursor: pointer;
			transition: all 0.2s ease;
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);

			@include mq('mobile', 'max') {
				width: 36px;
				height: 36px;
			}

			&:hover,
			&:focus {
				background: rgba(255, 255, 255, 1);
				transform: scale(1.1);
				box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
			}

			&:active {
				transform: scale(0.95);
			}

			svg {
				color: #333;
			}
		}
	}

	:global(body:has(.dashboard-overlay)) {
		overflow: hidden;
	}

	// Mobile responsive global styles
	@include mq('mobile', 'max') {
		:global {
			html {
				font-size: 14px;
			}
		}
	}

	@include mq('small-mobile', 'max') {
		:global {
			html {
				font-size: 13px;
			}
		}
	}

	// Touch-friendly improvements
	@include touch-device {
		.close-button {
			min-height: 44px;
			min-width: 44px;
		}
	}
</style>
