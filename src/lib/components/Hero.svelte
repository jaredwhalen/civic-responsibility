<script>
	import { onMount } from 'svelte';
	import { base } from '$app/paths';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import { slide, fade } from 'svelte/transition';

	let {
		videoSrc = '/assets/videos/web-bg.mp4',
		poster = '/assets/videos/placeholder.jpg',
		heroText = '',
		onScrollClick = () => {}
	} = $props();

	let isMounted = $state(false);

	onMount(() => {
		console.log('Hero mounted');
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
				<h1 transition:slide={{ axis: 'y', duration: 500, delay: 150 }}>What do we</h1>
				<h1 transition:slide={{ axis: 'y', duration: 500, delay: 300 }}>owe each other</h1>
				<h1 transition:slide={{ axis: 'y', duration: 500, delay: 450 }}>as Americans?</h1>

				<!-- <span class="scroll-indicator">↓ Scroll down </span> -->
			</div>

			<span class="scroll-indicator" transition:fade={{ duration: 500, delay: 600 }}
				>↓ Scroll down
			</span>
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
			// background: radial-gradient(circle, rgba(255, 255, 255, 0) 0%, rgba(0, 0, 0, 0.5) 80%);
			background: #000;
			background: linear-gradient(180deg, rgba(0, 0, 0, 0.1) 0%, rgba(0, 0, 0, 0.6) 100%);
			// background: #64707d;
			// background: linear-gradient(
			// 	144deg,
			// 	rgba(192, 36, 17, 1) 0%,
			// 	rgba(245, 245, 245, 1) 45%,
			// 	rgba(245, 245, 245, 1) 65%,
			// 	rgba(10, 38, 78, 1) 100%
			// );
			// mix-blend-mode: color;
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
			// max-width: 1400px;
			// margin: 0 auto;
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
						animation: highlightGrow 0.5s ease-out forwards;
						animation-delay: 500ms; // Start after first text appears
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

	.scroll-indicator {
		background: none;
		border: none;
		color: $color-beacon-white;
		font-size: 1.5rem;
		// margin: 0 auto;
		// cursor: pointer;
		// display: flex;
		// flex-direction: column;
		// align-items: center;
		padding: $spacing-sm;
		border-radius: 8px;
		transition: all 0.2s ease;
		margin-top: 50px;
		margin-left: 50px;

		// Mobile responsive sizing
		@include mq('mobile', 'max') {
			font-size: 1rem;
			padding: $spacing-xs;
		}

		// Touch-friendly improvements
		@include touch-device {
			min-height: 44px;
			min-width: 44px;
		}

		&:hover,
		&:focus {
			background: rgba(255, 255, 255, 0.1);
			transform: translateY(-2px);
			outline: 2px solid rgba(255, 255, 255, 0.3);
			outline-offset: 2px;
		}

		&:active {
			transform: translateY(0);
		}

		.arrow {
			font-size: 1rem;
			margin-top: 5px;
			transition: transform 0.2s ease;

			@include mq('mobile', 'max') {
				font-size: 0.9rem;
				margin-top: 4px;
			}

			// animation: bounce 2s infinite;
		}

		&:hover .arrow,
		&:focus .arrow {
			transform: translateY(2px);
		}
	}

	// @keyframes bounce {
	// 	0%,
	// 	20%,
	// 	50%,
	// 	80%,
	// 	100% {
	// 		transform: translateY(0);
	// 	}
	// 	40% {
	// 		transform: translateY(-5px);
	// 	}
	// 	60% {
	// 		transform: translateY(-5px);
	// 	}
	// }

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
