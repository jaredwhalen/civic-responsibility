<script>
	import Background from './Background.svelte';
	export let slideCount = 5;
	let currentSlide = 0;
	let isScrolling = false;
	let slides = [];

	import { onMount } from 'svelte';

	onMount(() => {
		handleScroll();
		window.addEventListener('scroll', handleScroll);
		return () => window.removeEventListener('scroll', handleScroll);
	});

	function handleScroll() {
		if (isScrolling) return;
		const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
		const windowHeight = window.innerHeight;
		const newSlide = Math.floor(scrollTop / windowHeight);
		if (newSlide !== currentSlide && newSlide >= 0 && newSlide < slideCount) {
			currentSlide = newSlide;
		}
	}

	function scrollToSlide(slideIndex) {
		isScrolling = true;
		window.scrollTo({
			top: slideIndex * window.innerHeight,
			behavior: 'smooth'
		});
		setTimeout(() => {
			isScrolling = false;
		}, 1000);
	}
</script>

<div class="scrolly-wrapper">
	<Background />
	<div class="scrolly-container">
		<slot />
	</div>
</div>

<div class="slide-nav">
	{#each Array(slideCount) as _, index}
		<button
			class="nav-dot {currentSlide === index ? 'active' : ''}"
			on:click={() => scrollToSlide(index)}
			aria-label={`Go to slide ${index + 1}`}
		></button>
	{/each}
</div>

<style lang="scss">
.scrolly-wrapper {
	position: relative;
	min-height: calc(100vh * var(--slide-count, 5));
}

.scrolly-bg {
	position: sticky;
	top: 0;
	width: 100%;
	height: 100vh;
	background: yellow;
	z-index: 0;
}

.scrolly-container {
	position: relative;
	z-index: 1;
}

.slide-nav {
	position: fixed;
	right: $spacing-lg;
	top: 50%;
	transform: translateY(-50%);
	z-index: 1001;
	display: flex;
	flex-direction: column;
	gap: $spacing-sm;
	.nav-dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		background: rgba(0, 0, 0, 0.3);
		border: none;
		cursor: pointer;
		transition: all 0.3s ease;
		margin: 2px 0;
		&:hover {
			background: #b6e36c;
			transform: scale(1.2);
		}
		&.active {
			background: #b6e36c;
			transform: scale(1.3);
		}
	}
}
</style>
