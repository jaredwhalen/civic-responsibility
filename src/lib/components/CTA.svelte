<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import smoothScroll from '$lib/helpers/smoothScroll.js';

	let { interactiveMode = $bindable(), showQuiz = $bindable() } = $props();
	let ctaElement;
	let textElement;
	let exploreButton;
	let quizButton;
	let underlineElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 20 ? 1 : 0);
	let textY = $derived(progress >= 20 ? 0 : 30);
	let buttonOpacity = $derived(progress >= 20 ? 1 : 0);
	let buttonScale = $derived(progress >= 20 ? 1 : 0.8);
	let underlineProgress = $derived(Math.max(0, Math.min(1, (progress - 20) / 30))); // 20-50% scroll

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states
		gsap.set(textElement, { opacity: 0, y: 30 });
		gsap.set(exploreButton, { opacity: 0, scale: 0.8 });
		gsap.set(quizButton, { opacity: 0, scale: 0.8 });

		// Create scroll trigger for this section
		const trigger = ScrollTrigger.create({
			trigger: ctaElement,
			start: 'top 80%',
			end: 'bottom 20%',
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

		if (exploreButton) {
			gsap.to(exploreButton, {
				opacity: buttonOpacity,
				scale: buttonScale,
				duration: 0.1,
				ease: 'none'
			});
		}

		if (quizButton) {
			gsap.to(quizButton, {
				opacity: buttonOpacity,
				scale: buttonScale,
				duration: 0.1,
				ease: 'none'
			});
		}

		if (underlineElement) {
			const underlineWidth = underlineProgress * 100;
			gsap.set(underlineElement, {
				'--underline-width': `${underlineWidth}%`,
				duration: 0.1,
				ease: 'none'
			});
		}
	});

	function handleExploreClick() {
		// Get the transition element and scroll so its bottom is at the bottom of the viewport
		const transitionElement = document.querySelector('.transition');
		if (transitionElement) {
			const elementRect = transitionElement.getBoundingClientRect();
			const elementBottom = elementRect.bottom;
			const viewportHeight = window.innerHeight;
			const scrollOffset = elementBottom - viewportHeight;

			// If already at the right position, activate immediately
			if (Math.abs(scrollOffset) < 10) {
				interactiveMode = true;
				return;
			}

			// Scroll and activate when complete
			window.scrollBy({
				top: scrollOffset,
				behavior: 'smooth'
			});

			// Listen for scroll completion
			let scrollTimeout;
			const checkScrollComplete = () => {
				clearTimeout(scrollTimeout);
				scrollTimeout = setTimeout(() => {
					// Check if scroll has stopped
					const newElementRect = transitionElement.getBoundingClientRect();
					const newScrollOffset = newElementRect.bottom - window.innerHeight;

					if (Math.abs(newScrollOffset) < 10) {
						interactiveMode = true;
					} else {
						// Continue checking
						checkScrollComplete();
					}
				}, 100);
			};

			checkScrollComplete();
		}
	}
</script>

<div class="cta-section" bind:this={ctaElement}>
	<div class="cta-content">
		<div class="cta-text" bind:this={textElement}>
			<div class="text-block large">
				Use the <span class="animated-underline" bind:this={underlineElement}>dashboard below</span>
				to explore how the data breaks down along demographic lines, gender, location, and more.
			</div>
			<div class="text-block">
				Or take our <button data-button="quiz" bind:this={quizButton} onclick={() => showQuiz = true}>interactive quiz</button> to see
				how your beliefs compare to those of other Americans.
			</div>
		</div>
	</div>
</div>

<style lang="scss">
	@import '../styles/variables.scss';

	.cta-section {
		width: 100%;
		padding: 15vh 4rem;
		background: linear-gradient(135deg, var(--color-theme-blue), #111);
		position: relative;
		z-index: 5;
	}

	.cta-content {
		max-width: 1200px;
		margin: 0 auto;
		display: flex;
		justify-content: center;
		align-items: center;
		gap: 2rem;
	}

	.cta-text {
		text-align: center;
		color: var(--color-theme-light);
		will-change: transform, opacity;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 2rem;

		.text-block {
			margin-bottom: 2rem;
			font-size: 1.4rem;
			line-height: 1.6;

			&.large {
				font-size: 2.5rem;
			}

			&:last-child {
				margin-bottom: 0;
			}
		}

		.animated-underline {
			position: relative;
			display: inline-block;

			&::after {
				content: '';
				position: absolute;
				bottom: -4px;
				left: 0;
				width: var(--underline-width, 0%);
				height: 3px;
				background: var(--color-theme-light);
			}
		}
	}

	button {
		padding: 0.5rem 0.5rem;
		border-radius: 8px;
		margin: 0 0.25rem;
		border: none;
		cursor: pointer;
		display: inline-block;
		font-size: inherit;
		font-weight: 600;
		transition: all 0.3s ease;
		will-change: transform, opacity;

		&:hover {
			transform: translateY(-2px);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
		}

		&[data-button='explore'] {
			background: var(--color-theme-light);
			color: var(--color-theme-dark);

			&:hover {
				background: #f0f0f0;
			}
		}

		&[data-button='quiz'] {
			background: var(--color-theme-blue-light);
			color: var(--color-theme-blue);
			&:hover {
				
				background: #f0f0f0;
			}
		}
	}
</style>
