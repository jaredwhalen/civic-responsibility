<script>
	import Scrolly from '$lib/components/scrolly/Scrolly.svelte';
	import Slide from '$lib/components/scrolly/Slide.svelte';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import DebugPanel from '$lib/components/DebugPanel.svelte';
	import copy from '$lib/data/copy.json';

	const { meta, content } = copy;

	// Scroll tracking state
	let currentSlide = $state(0);
	let scrollProgress = $state(0);
	let scrollDirection = $state('none');

	function scrollToScrolly() {
		window.scrollTo({ top: window.innerHeight, behavior: 'smooth' });
	}

	function handleScrollUpdate(metrics) {
		currentSlide = metrics.currentSlide;
		scrollProgress = metrics.scrollProgress;
		scrollDirection = metrics.scrollDirection;
		
		// Log the scroll metrics
		console.log('Scroll Metrics:', {
			currentSlide: metrics.currentSlide,
			scrollProgress: metrics.scrollProgress.toFixed(3),
			scrollDirection: metrics.scrollDirection
		});
	}
</script>

<svelte:head>
	<title>{meta.title}</title>
</svelte:head>

<!-- Header: Hamburger + Logos -->
<header class="main-header">
	<div class="header-left">
		<button class="hamburger" aria-label="Open menu">
			<span></span><span></span><span></span>
		</button>
	</div>
	<div class="header-right">
		<div class="logo logo-mic">More in Common</div>
		<div class="logo logo-beacon">BEACON PROJECT</div>
	</div>
</header>

<Hero
	videoSrc={content.hero.video || '/videos/web-bg.mp4'}
	poster={content.hero.poster || '/videos/placeholder.jpg'}
	heroText={content.hero.text}
	onScrollClick={scrollToScrolly}
/>

<!-- Debug Panel -->
<DebugPanel {currentSlide} {scrollProgress} {scrollDirection} />

<!-- Scrolly Slides -->
<Scrolly 
	slideCount={content.scrolly.slides.length}
	onScrollUpdate={handleScrollUpdate}
>
	{#each content.scrolly.slides as slide, index}
		<Slide content={slide} className="slide-{index}" {index} />
	{/each}
</Scrolly>

<Footer />

<style lang="scss">
body {
	background: #222;
}

.main-header {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: $spacing-md $spacing-lg;
	z-index: 2000;
	background: transparent;
	pointer-events: none;

	.header-left,
	.header-right {
		pointer-events: auto;
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
</style>
