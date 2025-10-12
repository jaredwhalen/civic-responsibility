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


</script>

<div class="cta-section" bind:this={ctaElement}>
	<div class="cta-content">
		<div class="cta-title" bind:this={textElement}>
			<h2>Dive deeper into the data...</h2>
		</div>
		
		<div class="cta-columns">
			<div class="cta-column dashboard-column">
				<div class="column-content">
					<h3>Dashboard</h3>
					<p>Explore how the data breaks down along demographic lines, gender, location, and more.</p>
					<button data-button="explore" bind:this={exploreButton} onclick={() => window.location.href = '/dashboard'}>
						Explore the data
					</button>
				</div>
			</div>
			
			<div class="cta-column quiz-column">
				<div class="column-content">
					<h3>Interactive Quiz</h3>
					<p>Take our interactive quiz to see how your beliefs compare to those of other Americans.</p>
					<button data-button="quiz" bind:this={quizButton} onclick={() => window.location.href = '/quiz'}>
						Start the quiz
					</button>
				</div>
			</div>
		</div>
		
		<div class="cta-footer">
			<button data-button="report" class="report-button">
				Read the full report
			</button>
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
		flex-direction: column;
		align-items: center;
		gap: 3rem;
	}

	.cta-title {
		text-align: center;
		color: var(--color-theme-light);
		will-change: transform, opacity;

		h2 {
			font-size: 2.5rem;
			font-weight: 600;
			margin: 0;
			line-height: 1.2;
		}
	}

	.cta-columns {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 3rem;
		width: 100%;
		max-width: 1000px;
	}

	.cta-column {
		display: flex;
		flex-direction: column;
		align-items: center;
		text-align: center;
		padding: 2rem;
		background: rgba(255, 255, 255, 0.05);
		border-radius: 16px;
		border: 1px solid rgba(255, 255, 255, 0.1);
		transition: all 0.3s ease;

		&:hover {
			background: rgba(255, 255, 255, 0.08);
			transform: translateY(-4px);
		}

		.column-content {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 1.5rem;
			color: var(--color-theme-light);

			h3 {
				font-size: 1.8rem;
				font-weight: 600;
				margin: 0;
				color: var(--color-theme-light);
			}

			p {
				font-size: 1.1rem;
				line-height: 1.6;
				margin: 0;
				max-width: 300px;
			}
		}
	}

	.cta-footer {
		display: flex;
		justify-content: center;
		width: 100%;
		margin-top: 2rem;
	}

	button {
		padding: 1rem 2rem;
		border-radius: 12px;
		border: none;
		cursor: pointer;
		display: inline-block;
		font-size: 1rem;
		font-weight: 600;
		transition: all 0.3s ease;
		will-change: transform, opacity;
		min-width: 160px;

		&:hover {
			transform: translateY(-2px);
			box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
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
				background: #e8f4fd;
			}
		}

		&.report-button {
			background: transparent;
			color: var(--color-theme-light);
			border: 2px solid var(--color-theme-light);
			padding: 1rem 2.5rem;
			font-size: 1.1rem;
			min-width: 200px;

			&:hover {
				background: var(--color-theme-light);
				color: var(--color-theme-dark);
			}
		}
	}

	// Responsive design
	@media (max-width: 768px) {
		.cta-columns {
			grid-template-columns: 1fr;
			gap: 2rem;
		}

		.cta-title h2 {
			font-size: 2rem;
		}

		.cta-column .column-content h3 {
			font-size: 1.5rem;
		}

		.cta-column .column-content p {
			font-size: 1rem;
		}
	}
</style>
