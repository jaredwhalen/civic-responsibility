<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import { isMobile } from '$lib/stores/responsive.js';

	let stepElement;
	let textElement;
	let dividedElement;
	let disillusionedElement;
	let distrustfulElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 20 ? 1 : 0); // Text appears at 20% scroll
	let textY = $derived(progress >= 20 ? 0 : -30); // Text starts above and moves to center

	// Individual line animations - each line flies in at different scroll points
	let dividedProgress = $derived(Math.max(0, Math.min(1, (progress - 15) / 15)));
	let disillusionedProgress = $derived(Math.max(0, Math.min(1, (progress - 30) / 15)));
	let distrustfulProgress = $derived(Math.max(0, Math.min(1, (progress - 45) / 15)));

	// Calculate positions directly from scroll progress
	let dividedX = $derived(300 - dividedProgress * 300); // 300px to 0px
	let disillusionedX = $derived(300 - disillusionedProgress * 300);
	let distrustfulX = $derived(300 - distrustfulProgress * 300);

	// Underline visibility states
	let dividedUnderline = $derived(dividedProgress > 0.7);
	let disillusionedUnderline = $derived(disillusionedProgress > 0.7);
	let distrustfulUnderline = $derived(distrustfulProgress > 0.7);

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states
		gsap.set(textElement, { opacity: 0, y: -30 });
		gsap.set(dividedElement, {
			x: 300,
			opacity: 0
		});
		gsap.set(disillusionedElement, {
			x: 300,
			opacity: 0
		});
		gsap.set(distrustfulElement, {
			x: 300,
			opacity: 0
		});

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

		if (dividedElement) {
			gsap.set(dividedElement, {
				x: dividedX,
				opacity: dividedProgress
			});
		}

		if (disillusionedElement) {
			gsap.set(disillusionedElement, {
				x: disillusionedX,
				opacity: disillusionedProgress
			});
		}

		if (distrustfulElement) {
			gsap.set(distrustfulElement, {
				x: distrustfulX,
				opacity: distrustfulProgress
			});
		}
	});
</script>

<div class="step-2" bind:this={stepElement}>
	<div class="text-content" bind:this={textElement}>
		<div class="text-body"><span class="text-accent">We are increasingly</span></div>

		{#if $isMobile}
			<!-- Mobile: Break into two lines -->
			<div class="d-words text-body">
				<div class="d-word" bind:this={dividedElement} class:visible={dividedUnderline}>
					<span class="text-accent">divided</span> in our beliefs,
				</div>
				<div class="d-word" bind:this={disillusionedElement} class:visible={disillusionedUnderline}>
					<span class="text-accent">disillusioned</span> with our politics, and
				</div>
				<div class="d-word" bind:this={distrustfulElement} class:visible={distrustfulUnderline}>
					 <span class="text-accent">distrustful</span> of each other.
				</div>
			</div>
		{:else}
			<!-- Desktop: Original layout -->
			<div class="d-words text-body">
				<div class="d-word" bind:this={dividedElement} class:visible={dividedUnderline}>
					<span class="text-accent">divided</span> in our beliefs,
				</div>
				<div class="d-word" bind:this={disillusionedElement} class:visible={disillusionedUnderline}>
					<span class="text-accent">disillusioned</span> with our politics, and
				</div>
				<div class="d-word" bind:this={distrustfulElement} class:visible={distrustfulUnderline}>
					<span class="text-accent">distrustful</span> of each other.
				</div>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';
	@import '../../../../styles/mixins.scss';

	.step-2 {
		height: 150vh;
		position: relative;
		display: flex;
		align-items: center;
		justify-content: center;
		width: 100%;
		color: var(--color-theme-light);
		// overflow-x: hidden; // Prevent horizontal overflow from GSAP animations
		z-index: 2;

		@include mq('mobile', 'max') {
			height: 100vh;
		}

		.text-content {
			position: sticky;
			top: 50vh;
			transform: translateY(-50%);
			width: 100%;
			padding: 2rem;
			text-align: center;
			z-index: 2;
			max-width: 900px;
			padding-bottom: 10rem;
			overflow-x: clip;
			will-change: transform, opacity; // GPU acceleration

			@include mq('mobile', 'max') {
				padding: 2rem 1rem;
			}


			.text-body {
				margin: 0 0 1rem 0;
				
			}

			.d-words {
				display: flex;
				flex-direction: column;
				align-items: flex-start;
				gap: 1rem;
				width: 100%;
				text-align: left;
				
			
				// Mobile responsive adjustments
				@include mq('mobile', 'max') {
					// align-items: center;
					// text-align: center;
					gap: 0.5rem;
				}

				.d-word {
					white-space: nowrap;
					position: relative;
					overflow-x: visible; // Allow the word itself to animate
					will-change: transform, opacity; // GPU acceleration

					// Mobile responsive adjustments
					@include mq('mobile', 'max') {
						white-space: normal;
						// text-align: center;
					}

					.text-accent {
						
						&::after {
							content: '';
							position: absolute;
							bottom: -3px;
							left: 0;
							width: 100%;
							height: 4px;
							background: var(--color-theme-red);
							transform: scaleX(0);
							transform-origin: left;
							transition: transform 0.6s ease;
							z-index: 1;
							border-radius: 2px;
						}

						color: var(--color-theme-blue-light);
					}

					// Show underline when word is visible
					&.visible .text-accent::after {
						transform: scaleX(1) !important;
					}

					&:hover {
						transform: translateY(-2px) scale(1.02);
						transition: transform 0.3s ease;
					}
				}
			}
		}
	}
</style>
