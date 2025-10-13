<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';

	let stepElement;
	let textElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	// Fade in between 20% and 50% of scroll progress
	let textOpacity = $derived(Math.max(0, Math.min(1, (progress - 20) / 30)));
	let textY = $derived(20 - textOpacity * 20); // Start 20px below and move up

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial state
		gsap.set(textElement, { opacity: 0, y: 20 });

		// Create scroll trigger for this section
		const trigger = ScrollTrigger.create({
			trigger: stepElement,
			start: 'top bottom',
			end: 'bottom top',
			onUpdate: (self) => {
				progress = self.progress * 100;
			}
		});

		return () => {
			trigger.kill();
		};
	});

	// Watch for progress changes and update animations
	$effect(() => {
		if (textElement) {
			gsap.to(textElement, {
				opacity: textOpacity,
				y: textY,
				duration: 0.1,
				ease: 'none'
			});
		}
	});
</script>

<div class="step-12" bind:this={stepElement}>
	<div class="text-content" bind:this={textElement}>
		<div class="text-body">
			Yet despite these differences, <b>93% of Americans</b> agree on one thing…
		</div>
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-12 {
		height: 50vh;
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		width: 100%;
		background: var(--bg-color);
		gap: 4rem;
		margin-top: -1px;

		.text-content {
			width: 100%;
			padding: 2rem;
			text-align: center;
			z-index: 10;
			max-width: 900px;
			will-change: transform, opacity;

			.text-body {
				text-align: center;
				font-size: 2.8rem;
				font-weight: 300;

				@include mq('mobile', 'max') {
					font-size: 2rem;
				}

				b {
					font-weight: 600;
					color: var(--color-theme-blue);
				}
			}
		}
	}
</style>
