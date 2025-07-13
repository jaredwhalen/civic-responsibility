<script>
	export let videoSrc = '/videos/web-bg.mp4';
	export let poster = '/videos/placeholder.jpg';
	export let heroText = '';
	export let onScrollClick = () => {};
</script>

<section class="hero-section">
	<div class="hero-video-bg">
		<video autoplay muted loop playsinline poster={poster}>
			<source src={videoSrc} type="video/mp4" />
		</video>
		<div class="hero-video-blur"></div>
	</div>
	<div class="hero-content">
		<h1 class="hero-title">{heroText}</h1>
		<button class="scroll-indicator" on:click={onScrollClick}>
			<span>Scroll down</span>
			<div class="arrow">▼</div>
		</button>
	</div>
</section>

<style lang="scss">
.hero-section {
	position: relative;
	height: 100vh;
	overflow: hidden;
	display: flex;
	align-items: center;
	justify-content: center;
	width: 100%;
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
		backdrop-filter: blur(6px);
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
	max-width: 900px;
	margin: 0 auto;
	padding: 0 $spacing-lg;
	.hero-title {
		font-size: 2.2rem;
		font-weight: 400;
		letter-spacing: 0.04em;
		line-height: 1.2;
		margin-bottom: $spacing-xl;
		text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
		@include respond-to(md) {
			font-size: 3.2rem;
		}
	}
}
.scroll-indicator {
	background: none;
	border: none;
	color: #b6e36c;
	font-size: 1.1rem;
	margin: 0 auto;
	cursor: pointer;
	display: flex;
	flex-direction: column;
	align-items: center;
	.arrow {
		font-size: 2rem;
		animation: bounce 2s infinite;
	}
}
@keyframes bounce {
	0%,
	20%,
	50%,
	80%,
	100% {
		transform: translateY(0);
	}
	40% {
		transform: translateY(-10px);
	}
	60% {
		transform: translateY(-5px);
	}
}
</style> 