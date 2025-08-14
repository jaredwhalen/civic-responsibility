<script>
	/**
	 * @typedef {Object} Props
	 * @property {string} [videoSrc]
	 * @property {string} [poster]
	 * @property {string} [heroText]
	 * @property {any} [onScrollClick]
	 */

	/** @type {Props} */
	let {
		videoSrc = '/assets/videos/web-bg.mp4',
		poster = '/assets/videos/placeholder.jpg',
		heroText = '',
		onScrollClick = () => {}
	} = $props();
</script>

<section class="hero-section">
	<div class="hero-video-bg">
		<video autoplay muted loop playsinline {poster}>
			<source src={videoSrc} type="video/mp4" />
		</video>
		<div class="hero-video-overlay"></div>
		<div class="hero-video-blur"></div>
	</div>
	<div class="hero-content">
		<h1 class="hero-title">{@html heroText}</h1>
		<button class="scroll-indicator" onclick={onScrollClick}>
			<span>Scroll down</span>
			<div class="arrow">▼</div>
		</button>
	</div>
</section>

<style lang="scss">
	:global {
		.hero-section {
			position: relative;
			height: 100vh;
			overflow: hidden;
			display: flex;
			align-items: center;
			justify-content: center;
			width: 100%;
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

			.hero-title {
				font-size: 4rem;
				font-weight: 400;
				letter-spacing: 0.04em;
				line-height: 1.2;
				margin-bottom: $spacing-xl;
				text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
				font-family: $font-family-body;

				span {
					font-size: 5.5rem;
					font-family: $font-family-title;
					font-weight: 400;
					color: $color-beacon-yellow;
					letter-spacing: -2px;
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
		.arrow {
			font-size: 1rem;
			margin-top: 5px;
			// animation: bounce 2s infinite;
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
