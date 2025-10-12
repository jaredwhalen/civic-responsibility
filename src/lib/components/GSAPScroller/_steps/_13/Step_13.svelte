<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	let stepElement;
	let textElement;
	let progress = $state(0);
	let animatedNumber = $state(0);
	let counterAnimation;

	// Reactive calculations based on scroll progress
	let firstLineProgress = $derived(Math.max(0, Math.min(1, (progress - 15) / 20))); // 15-35% scroll
	let secondLineProgress = $derived(Math.max(0, Math.min(1, (progress - 25) / 25))); // 25-50% scroll

	// Overall opacity for the entire content block (text + chart)
	let overallContentOpacity = $derived(() => {
		// Fade in from 0 to 1 between 15% and 35% (aligned with first line animation)
		if (progress >= 15 && progress <= 35) {
			return (progress - 15) / 20;
		}
		// Stay at 1 between 35% and 70%
		if (progress > 35 && progress < 70) {
			return 1;
		}
		// Fade out from 1 to 0 between 70% and 90%
		if (progress >= 70 && progress <= 90) {
			return 1 - (progress - 70) / 20;
		}
		// Outside these ranges, it's 0
		return 0;
	});

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states
		gsap.set(textElement, { opacity: 0 });

		// Set initial states for both lines
		const firstLine = textElement?.querySelector('.first-line');
		const secondLineWords = textElement?.querySelectorAll('.second-line .word');

		if (firstLine) {
			gsap.set(firstLine, { opacity: 0, y: -50 });
		}

		if (secondLineWords) {
			gsap.set(secondLineWords, { opacity: 0, y: 30, scale: 0.8 });
		}

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
			if (counterAnimation) {
				counterAnimation.kill();
			}
		};
	});

	// Watch for progress changes and update animations
	$effect(() => {
		if (textElement) {
			gsap.to(textElement, {
				opacity: overallContentOpacity, // Use overall opacity
				duration: 0.1,
				ease: 'none'
			});

			// Animate first line (slides down from top)
			const firstLine = textElement.querySelector('.first-line');
			if (firstLine) {
				const firstLineOpacity = firstLineProgress;
				const firstLineY = -50 + firstLineProgress * 50;

				gsap.set(firstLine, {
					opacity: firstLineOpacity,
					y: firstLineY,
					duration: 0.1,
					ease: 'none'
				});
			}

			// Animate second line words (one by one)
			const secondLineWords = textElement.querySelectorAll('.second-line .word');
			secondLineWords.forEach((word, index) => {
				const wordProgress = Math.max(0, Math.min(1, (secondLineProgress - index * 0.15) / 0.4));
				const wordOpacity = wordProgress;
				const wordY = 30 - wordProgress * 30;
				const wordScale = 0.8 + wordProgress * 0.2;

				gsap.set(word, {
					opacity: wordOpacity,
					y: wordY,
					scale: wordScale,
					duration: 0.1,
					ease: 'none'
				});
			});

			// Handle counter animation based on progress
			if (progress > 25) {
				// Start animation if not already running
				if (!counterAnimation || !counterAnimation.isActive()) {
					const counterObj = { value: animatedNumber };
					counterAnimation = gsap.to(counterObj, {
						value: 93,
						duration: 3,
						ease: 'power2.out',
						onUpdate: function () {
							animatedNumber = Math.round(counterObj.value);
						}
					});
				}
			} else {
				// Reset when progress is below 5%
				if (counterAnimation) {
					counterAnimation.kill();
				}
				animatedNumber = 0;
			}
		}
	});
</script>

<div class="step-13" bind:this={stepElement}>
	<div class="sticky-container">
		<div class="text-content" bind:this={textElement}>
			<div class="text-body">
				<div class="first-line">Now more than ever, it is important to</div>
				<div class="second-line">
					<span class="word first-word">honor</span> <span class="word">our</span>
					<span class="word">civic</span> <span class="word last-word">responsibilities.</span>
				</div>
			</div>
		</div>

		<div class="big-number-container">
			<div class="big-number">{animatedNumber}%</div>
			<div class="agree-text">agree</div>
		</div>
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-13 {
		height: 150vh;
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		width: 100%;
		background: var(--bg-color);
		gap: 4rem;
		margin-top: -1px;

		.sticky-container {
			position: sticky;
			top: 15vh;
			width: 100%;
			z-index: 10;
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 2rem;
		}

		.text-content {
			width: 100%;
			padding: 2rem;
			text-align: center;
			z-index: 10;
			max-width: 900px;
			will-change: transform, opacity;

			.text-body {
				text-align: center;

				.first-line {
					font-size: 2.5rem;
					font-weight: 300;
					line-height: 1.3;
					margin-bottom: 1rem;
					opacity: 0;
					transform: translateY(-50px);
				}

				.second-line {
					position: relative;
					font-size: 4.5rem;
					font-weight: 600;
					line-height: 1.1;
					color: var(--color-theme-blue);
					width: min-content;
					margin: 0 auto;

					.word {
						display: inline-block;
						transform-style: preserve-3d;
						opacity: 0;
						transform: translateY(30px) scale(0.8);
					}

					.first-word {
						position: relative;

						&::before {
							content: '“';
							position: absolute;
							// left: -4rem;
							// top: -1rem;
							top: -20px;
							left: -90px;
							font-size: 12rem;
							font-weight: 700;
							color: var(--color-theme-blue-light);
							opacity: 0.6;
							line-height: 1;
						}
					}

					.last-word {
						position: relative;

						&::after {
							content: '”';
							position: absolute;
							// right: -4rem;
							// bottom: -1rem;
							top: -20px;
							right: -90px;
							font-size: 12rem;
							font-weight: 700;
							color: var(--color-theme-blue-light);
							opacity: 0.6;
							line-height: 1;
						}
					}
				}
			}
		}
	}

	.big-number-container {
		// position: absolute;
		padding-bottom: 10rem;
		.big-number {
			font-size: 30vh;
			line-height: 1;
			font-weight: 600;
			color: var(--color-theme-blue-light);
			font-family: $font-family-mono;
		}

		.agree-text {
			font-size: 2rem;
			font-weight: 600;
			color: var(--color-theme-blue-light);
			font-family: $font-family-sans;
			text-align: right;
			margin-top: -3rem;
		}
	}
</style>
