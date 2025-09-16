<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	
	let { i, progress = 0 } = $props();
	
	let slideElement;
	let textElement;
	let artElement;
	
	// Expose the slide element to parent
	export { slideElement };
	
	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 25 ? 1 : 0); // Text appears at 25% scroll
	let textY = $derived(progress >= 25 ? 0 : -50); // Text starts above and moves to center
	let artOpacity = $derived(progress >= 50 ? Math.min(1, (progress - 50) * 0.04) : 0); // 2% per 1% progress
	let isPinned = $derived(progress >= 0 && progress < 100);
	let isUnpinned = $derived(progress >= 100);
	
	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);
		
		// Set initial states
		gsap.set(textElement, { opacity: 0, y: -50 });
		gsap.set(artElement, { opacity: 0 });
	});
	
	// Watch for progress changes and update animations
	$effect(() => {
		if (textElement && artElement) {
			gsap.to(textElement, { 
				opacity: textOpacity,
				y: textY,
				duration: 0.1,
				ease: "none"
			});
			
			gsap.to(artElement, { 
				opacity: artOpacity, 
				duration: 0.1,
				ease: "none"
			});
		}
	});
</script>

<div class="pin-slide" bind:this={slideElement}>
	<div class="pin-slide-inner" bind:this={textElement}>
		<h1>Pin Slide {i + 1}</h1>
		<p>This is slide content that pins in the middle</p>
	</div>
	<div class="pin-slider-art" bind:this={artElement}>
		<div class="art-content">
			<h2>Art Content {i + 1}</h2>
			<p>This is the animated art section</p>
		</div>
	</div>
</div>

<style lang="scss">
	@import '../../styles/variables.scss';
	.pin-slide {
		height: var(--section-height);
		position: relative;
		display: flex;
		align-items: center;

		
		.pin-slide-inner {
			position: sticky;
			top: 50vh;
			left: 0;
			transform: translateY(-50%);
			width: 50%;
			max-width: 600px;
			padding: 2rem;
			text-align: left;
			z-index: 2;
			
			h1 {
				font-size: 3rem;
				font-weight: 700;
				color: $color-theme-dark;
				margin-bottom: 1rem;
			}
			
			p {
				font-size: 1.2rem;
				color: $color-theme-dark;
				margin: 0.5rem 0;
				opacity: 0.8;
			}
		}

		.pin-slider-art {
			position: absolute;
			top: 50%;
			right: 2rem;
			width: 60%;
			height: 60%;
			background: linear-gradient(135deg, $color-theme-blue, var(--color-theme-green));
			border-radius: 1rem;
			display: flex;
			align-items: center;
			justify-content: center;
			transform: translateY(-50%);
			box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
			z-index: 1;
			
			.art-content {
				text-align: center;
				color: white;
				
				h2 {
					font-size: 2rem;
					font-weight: 600;
					margin-bottom: 1rem;
				}
				
				p {
					font-size: 1.1rem;
					opacity: 0.9;
				}
			}
		}
	}
</style>
