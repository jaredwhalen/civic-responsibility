<script>
	import { onMount } from 'svelte';
	import { base } from '$app/paths';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import { slide, fade } from 'svelte/transition';

	let {
		videoSrc = '/assets/videos/web-bg.mp4',
		poster = '/assets/videos/placeholder.jpg',
		heroText = ''
	} = $props();

	let isMounted = $state(false);

	onMount(() => {
		isMounted = true;
	});
</script>

<section class="hero-section" role="banner" aria-label="Hero section">
	<div class="hero-video-bg" role="presentation" aria-hidden="true">
		<video autoplay muted loop playsinline {poster} aria-label="Background video">
			<source src={base + videoSrc} type="video/mp4" />
			<!-- Fallback for browsers that don't support video -->
			<p>Your browser doesn't support HTML5 video.</p>
		</video>
		<div class="hero-video-overlay"></div>
		<div class="hero-video-blur"></div>
	</div>
	<div class="hero-content">
		<!-- <h1 class="hero-title">{@html heroText}</h1> -->
		{#if isMounted}
			<div class="hero-title">
				<h1 transition:slide={{ axis: 'y', duration: 1000, delay: 150 }}>What do we</h1>
				<h1 transition:slide={{ axis: 'y', duration: 1000, delay: 300 }}>owe each other</h1>
				<h1 transition:slide={{ axis: 'y', duration: 1000, delay: 450 }}>as Americans?</h1>
			</div>
		{/if}
	</div>
	
</section>

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	:global {
		.hero-section {
			position: relative;
			height: 100vh;
			overflow: hidden;
			display: flex;
			align-items: center;
			justify-content: center;
			width: 100%;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				height: 100vh;
				min-height: 600px; // Ensure minimum height on mobile
			}

			@include mq('small-mobile', 'max') {
				min-height: 500px;
			}
		}

		.hero-video-overlay {
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			background: #000;
			background: linear-gradient(180deg, rgba(0, 0, 0, 0.1) 0%, rgba(0, 0, 0, 0.6) 100%);
		}

		.hero-video-bg {
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			z-index: 1;
			// filter: saturate(0);

			video {
				width: 100%;
				height: 100%;
				object-fit: cover;
			}

			.hero-video-blur {
				position: absolute;
				top: 0;
				left: 0;
				width: 100%;
				height: 100%;
				backdrop-filter: blur(4px);
				background: rgba(0, 0, 0, 0.25);
				z-index: 2;

				// Reduce blur on mobile for better performance
				@include mq('mobile', 'max') {
					backdrop-filter: blur(2px);
				}
			}
		}

		.hero-content {
			position: relative;
			z-index: 3;

			color: #fff;
			width: 100%;
			padding: 0 $spacing-lg;
			height: calc(100% - 200px);

			// Mobile responsive padding
			@include mq('mobile', 'max') {
				padding: 0 $spacing-md;
				max-width: 100%;
			}

			@include mq('small-mobile', 'max') {
				padding: 0 $spacing-sm;
			}

			.hero-title {
				font-weight: 400;
				letter-spacing: 0.04em;
				font-family: $font-family-title;
				text-align: left;
				display: flex;
				flex-direction: column;
				height: 100%;
				justify-content: center;
				padding-left: 50px;
				padding-bottom: 100px;
				// text-shadow: 0 2px 8px rgba(0, 0, 0, 0.25);z

				h1 {
					display: inline-block;
					margin: 0px;
					padding: 0px;
					line-height: 1;
					font-size: 9vw;
					position: relative;
					width: fit-content;
					padding: 0px 1vw;
					color: $color-beacon-white;

					&:after {
						content: '';
						display: block;
						width: 100%;
						height: 4vw;
						position: absolute;
						bottom: 0.5vw;
						left: 0;
						z-index: -1;

						// Animated highlight that grows from left to right
						transform: scaleX(0);
						transform-origin: left;
						animation: highlightGrow 1s ease-out forwards;
						animation-delay: 1000ms; // Start after first text appears
						// box-shadow: 0 2px 8px rgba(0, 0, 0, 0.25);
					}

					// border: 4px solid $color-beacon-white;

					&:nth-child(1) {
						&::after {
							background-color: $color-theme-blue;
						}
					}

					&:nth-child(2) {
						&::after {
							background-color: $color-theme-red;
						}
					}

					&:nth-child(3) {
						&::after {
							background-color: $color-theme-blue;
						}
					}
				}
			}
		}
	}

	// Keyframe animation for highlight growth
	@keyframes highlightGrow {
		0% {
			transform: scaleX(0);
		}
		100% {
			transform: scaleX(1);
		}
	}

	// Reduced motion support for accessibility
	@media (prefers-reduced-motion: reduce) {
		h1::after {
			animation: none !important;
			transform: scaleX(1) !important;
		}
	}
</style>
