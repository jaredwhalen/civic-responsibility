<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import smoothScroll from '$lib/helpers/smoothScroll.js';
	import Dashboard from './dashboard/Dashboard.svelte';

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
	<div class="cta-background">
		<Dashboard activeId="9999-dashboard" interactiveMode={true} />
	</div>
	<div class="cta-overlay"></div>
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
		// min-height: 100vh;
		display: flex;
		align-items: center;
		position: relative;
		isolation: isolate;
	}

	.cta-background {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		z-index: -2;
		pointer-events: none;
		
		:global(*) {
			pointer-events: none !important;
		}
	}

	.cta-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		z-index: -1;
		
		&::before {
			content: '';
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			// background: linear-gradient(135deg, var(--color-theme-blue), #111);
			// opacity: 0.95;
			// mix-blend-mode: multiply;

			background: linear-gradient(
				135deg,
				var(--color-theme-blue) 0%,
				var(--color-theme-blue-light) 100%
			);
			opacity: 0.75;
		}
	}

	.cta-content {
		max-width: 1200px;
		width: 100%;
		margin: 0 auto;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 3rem;
		position: relative;
		z-index: 10;
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
			text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
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
		padding: 2.5rem;
		@include glass-effect();
		border-radius: 20px;
		box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
		transition: all 0.3s ease;

		&:hover {
			transform: translateY(-6px);
			box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
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
				text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
			}

			p {
				font-size: 1.1rem;
				line-height: 1.6;
				margin: 0;
				max-width: 300px;
				opacity: 0.95;
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
			box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
		}

		&[data-button='explore'] {
			background: var(--color-theme-light);
			color: var(--color-theme-dark);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

			&:hover {
				background: #ffffff;
				box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
			}
		}

		&[data-button='quiz'] {
			background: var(--color-theme-blue-light);
			color: var(--color-theme-blue);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

			&:hover {
				// background: #ffffff;
				box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
			}
		}

		&.report-button {
			@include glass-effect(rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.6));
			color: var(--color-theme-light);
			border-width: 2px;
			padding: 1rem 2.5rem;
			font-size: 1.1rem;
			min-width: 200px;

			&:hover {
				background: var(--color-theme-light);
				color: var(--color-theme-dark);
				border-color: var(--color-theme-light);
			}
		}
	}

	// Responsive design
	@media (max-width: 768px) {
		.cta-section {
			padding: 10vh 2rem;
			min-height: auto;
		}

		.cta-background {
			position: absolute;
		}

		.cta-overlay {
			position: absolute;
		}

		.cta-columns {
			grid-template-columns: 1fr;
			gap: 2rem;
		}

		.cta-title h2 {
			font-size: 2rem;
		}

		.cta-column {
			padding: 2rem;

			.column-content h3 {
				font-size: 1.5rem;
			}

			.column-content p {
				font-size: 1rem;
			}
		}

		button {
			&.report-button {
				padding: 0.875rem 2rem;
				font-size: 1rem;
				min-width: 180px;
			}
		}
	}
</style>
