<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import smoothScroll from '$lib/helpers/smoothScroll.js';
	import Dashboard from './dashboard/Dashboard.svelte';
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';

	let { interactiveMode = $bindable(), showQuiz = $bindable() } = $props();
	let exploreElement;
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
			trigger: exploreElement,
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

<div id="explore" class="explore-section" bind:this={exploreElement}>
	<div class="explore-background">
		<Dashboard activeId="9999-dashboard" interactiveMode={true} disableTippy={true} />
	</div>
	<div class="explore-overlay"></div>
	<div class="explore-content">

		<!-- <iframe src="https://thebeaconproject.substack.com/embed" width="100%" height="150" scrolling="no"></iframe> -->

		<div class="explore-title" bind:this={textElement}>
			<h2>Explore further...</h2>
		</div>
		
		<div class="explore-columns">
			<div class="explore-column dashboard-column">
				<div class="column-content">
					<h3>Data Dashboard</h3>
					<p>Learn how Americans' beliefs differ by political affiliation, gender, location, and more.</p>
					<button data-button="explore" bind:this={exploreButton} onclick={() => goto(base + '/dashboard?fromExplore=true')}>
						Explore the data
					</button>
				</div>
			</div>
			
			<div class="explore-column quiz-column">
				<div class="column-content">
					<h3>Interactive Quiz</h3>
					<p>How do your beliefs compare to other Americans'</p>
					<button data-button="quiz" bind:this={quizButton} onclick={() => goto(base + '/quiz?fromExplore=true')}>
						Start the quiz
					</button>
				</div>
			</div>
		</div>
		
		<!-- <div class="explore-footer">
			<button data-button="report" class="report-button">
				Read the full report
			</button>
		</div> -->
	</div>
</div>

<style lang="scss">
	@import '../styles/variables.scss';

	.explore-section {
		width: 100%;
		padding: 15vh 4rem;
		// min-height: 100vh;
		display: flex;
		align-items: center;
		position: relative;
		isolation: isolate;
	}

	.explore-background {
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

	.explore-overlay {
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

	.explore-content {
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

	.explore-title {
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

	.explore-columns {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 3rem;
		width: 100%;
		max-width: 1000px;
	}

	.explore-column {
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

	.explore-footer {
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
		.explore-section {
			padding: 10vh 2rem;
			min-height: auto;
		}

		.explore-background {
			position: absolute;
		}

		.explore-overlay {
			position: absolute;
		}

		.explore-columns {
			grid-template-columns: 1fr;
			gap: 2rem;
		}

		.explore-title h2 {
			font-size: 2rem;
		}

		.explore-column {
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
