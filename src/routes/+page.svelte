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
</script>

<svelte:head>
	<title>{meta.title}</title>
</svelte:head>

<main style:--bg-color={'#f7f3ee'}>
	<header class="main-header">
		<div class="header-left">
			<!-- <button class="hamburger" aria-label="Open menu">
				<span></span><span></span><span></span>
			</button> -->
		</div>
		<div class="header-right">
			<img class="logo" src={base + '/assets/icons/Lockup_WhiteWhite.png'} alt="More in Common" />
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
		<div class="dashboard-overlay" transition:fade={{ duration: 250 }}>
			<div class="dashboard-overlay-content {showExpandedModal ? 'expanded' : ''}">
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
	>
		{#snippet background()}
			<div class="background-container" data-theme={activeSlide.theme || 'default'}>
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
			>
				{#each content.scrolly.slides as slide, index}
					<Slide content={slide} cls="slide-{index} {slide.cls}" {index} bind:interactiveMode />
				{/each}
			</div>
		{/snippet}
	</Scroller>

	<Footer />
</main>

<style lang="scss">
	:global {
		body {
			background: #f7f3ee;
		}

		.background-container {
			z-index: 0;
			position: relative;

			transition: background-color 0.75s ease;

			&[data-theme='default'] {
				background: $color-bg-light;
			}
			&[data-theme='dark'] {
				background-color: $color-beacon-dark-green;
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
					background: $color-bg-light;
				}
			}
			&[data-theme='dark'] {
				color: $color-beacon-white;
				.slide-inner p {
					background: $color-beacon-dark-green;
				}
			}

			&[data-theme='green'] {
				// $color-beacon-light-green: #64B42D;
				// $color-beacon-dark-green: #233219;
				background: #233219e6;
				color: $color-beacon-white;
				.slide-inner p {
					background: $color-beacon-dark-green;
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

		.header-left,
		.header-right {
			pointer-events: auto;

			.logo {
				height: auto;
				width: 100%;
				max-width: 300px;
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
		background: $color-beacon-light-green;
		box-sizing: border-box;
		padding: 0px;

		transition: all 0.5s ease;

		.dashboard-overlay-content {
			width: 100%;
			height: 100%;
			background: $color-bg-light;
			border-radius: 4px;
			box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
			overflow: hidden;
			transition: all 0.5s ease;

			&.expanded {
				width: calc(100% - 30px);
				height: calc(100% - 30px);
				margin: 15px;
				overflow: hidden;
			}
		}
	}

	:global(body:has(.dashboard-overlay)) {
		overflow: hidden;
	}
</style>
