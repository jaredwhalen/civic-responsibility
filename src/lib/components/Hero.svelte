<script>
	import { base } from '$app/paths';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	
	let {
		videoSrc = '/assets/videos/web-bg.mp4',
		poster = '/assets/videos/placeholder.jpg',
		heroText = '',
		onScrollClick = () => {}
	} = $props();
</script>

<section class="hero-section" role="banner" aria-label="Hero section">
	<div class="hero-video-bg" role="presentation" aria-hidden="true">
		<video 
			autoplay 
			muted 
			loop 
			playsinline 
			{poster}
			aria-label="Background video"
		>
			<source src={base + videoSrc} type="video/mp4" />
			<!-- Fallback for browsers that don't support video -->
			<p>Your browser doesn't support HTML5 video.</p>
		</video>
		<div class="hero-video-overlay"></div>
		<div class="hero-video-blur"></div>
	</div>
	<div class="hero-content">
		<h1 class="hero-title">{@html heroText}</h1>
		<button 
			class="scroll-indicator" 
			onclick={onScrollClick}
			aria-label="Scroll down to continue reading"
			type="button"
		>
			<span>Scroll down</span>
			<div class="arrow" aria-hidden="true">▼</div>
		</button>
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
			background: radial-gradient(circle, rgba(255, 255, 255, 0) 0%, rgba(0, 0, 0, 0.25) 100%);
		}
		
		.hero-video-bg {
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			z-index: 1;
			
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
			text-align: center;
			color: #fff;
			width: 100%;
			max-width: 1100px;
			margin: 0 auto;
			padding: 0 $spacing-lg;
			
			// Mobile responsive padding
			@include mq('mobile', 'max') {
				padding: 0 $spacing-md;
				max-width: 100%;
			}
			
			@include mq('small-mobile', 'max') {
				padding: 0 $spacing-sm;
			}

			.hero-title {
				font-size: 4rem;
				font-weight: 400;
				letter-spacing: 0.04em;
				line-height: 1.2;
				margin-bottom: $spacing-xl;
				text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
				font-family: $font-family-body;
				
				// Mobile responsive typography
				@include mq('desktop', 'max') {
					font-size: 3.5rem;
					margin-bottom: $spacing-lg;
				}
				
				@include mq('mobile', 'max') {
					font-size: 2.8rem;
					margin-bottom: $spacing-md;
					letter-spacing: 0.02em;
				}
				
				@include mq('small-mobile', 'max') {
					font-size: 2.2rem;
					margin-bottom: $spacing-sm;
					line-height: 1.3;
				}

				span {
					font-size: 5.5rem;
					font-family: $font-family-title;
					font-weight: 400;
					color: $color-beacon-yellow;
					letter-spacing: -2px;
					
					// Mobile responsive span sizing
					@include mq('desktop', 'max') {
						font-size: 4.8rem;
						letter-spacing: -1.5px;
					}
					
					@include mq('mobile', 'max') {
						font-size: 3.8rem;
						letter-spacing: -1px;
					}
					
					@include mq('small-mobile', 'max') {
						font-size: 3rem;
						letter-spacing: -0.5px;
					}
				}
			}
		}
	}

	.scroll-indicator {
		background: none;
		border: none;
		color: $color-beacon-yellow;
		font-size: 1.1rem;
		margin: 0 auto;
		cursor: pointer;
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: $spacing-sm;
		border-radius: 8px;
		transition: all 0.2s ease;
		
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
</style>
