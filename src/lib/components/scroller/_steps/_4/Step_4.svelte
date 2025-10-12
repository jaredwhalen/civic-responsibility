<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';

	let stepElement;
	let questionElement;
	let definitionElement;
	let progress = $state(0);
	let questionHeight = $state(0);
	let definitionHeight = $state(0);
	let maxHeight = $derived(Math.max(questionHeight, definitionHeight));

	// Reactive calculations based on scroll progress
	let questionProgress = $derived(Math.max(0, Math.min(1, (progress - 20) / 15))); // 20-35% scroll
	let questionOpacity = $derived(questionProgress);
	let questionX = $derived(-200 + questionProgress * 200); // Slides from -200 to 0

	// Definition flies in from right
	let definitionProgress = $derived(Math.max(0, Math.min(1, (progress - 35) / 15))); // 35-50% scroll
	let definitionOpacity = $derived(definitionProgress);
	let definitionX = $derived(200 - definitionProgress * 200); // Slides from 200 to 0

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Measure heights after elements are rendered
		if (questionElement) {
			questionHeight = questionElement.offsetHeight;
		}
		if (definitionElement) {
			definitionHeight = definitionElement.offsetHeight;
		}

		// Set initial states
		gsap.set(questionElement, { opacity: 0, x: -200 });
		gsap.set(definitionElement, {
			x: 200,
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
		if (questionElement) {
			gsap.set(questionElement, {
				opacity: questionOpacity,
				x: questionX
			});
		}

		if (definitionElement) {
			gsap.set(definitionElement, {
				x: definitionX,
				opacity: definitionOpacity
			});
		}
	});
</script>

<div class="step-4" bind:this={stepElement}>
	<div class="text-content" bind:this={questionElement} style:min-height="{maxHeight}px">
		<div class="text-body">
			We asked 5,000 Americans from all 50 states: <b
				>What are our civic responsibilities as Americans?</b
			>
		</div>
	</div>

	<div class="definition-content" bind:this={definitionElement} style:min-height="{maxHeight}px">
		<div class="dictionary-entry">
			<div class="term">
				<span class="term-text">civic responsibilities</span>
				<!-- <span class="pronunciation">SIV-ik rih-SPAHN-suh-BIL-uh-teez</span> -->
			</div>
			<div class="part-of-speech">noun phrase</div>
			<div class="definition-text">
				Behaviors people are expected to perform as upstanding members of our national community.
			</div>
		</div>
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-4 {
		height: 150vh;
		position: relative;
		display: flex;
		align-items: center;
		justify-content: center;
		width: 100%;

		color: var(--color-theme-light);

	.text-content {
		position: sticky;
		top: 50vh;
		transform: translateY(-50%);
		width: 50%;
		padding: 2rem;
		text-align: right;
		z-index: 10;
		max-width: 700px;
		display: flex;
		// align-items: center;
		justify-content: flex-end;
		b {
			color: var(--color-theme-blue-light);
		}
	}

	.definition-content {
		position: sticky;
		top: 50vh;
		transform: translateY(-50%);
		width: 50%;
		padding: 2rem;
		text-align: left;
		z-index: 5;
		max-width: 700px;
		display: flex;
		// align-items: center;
		justify-content: flex-start;

			.dictionary-entry {
				// background: var(--color-theme-blue-light);
				// border: 2px solid var(--color-theme-blue);
				border-radius: 12px;
				padding-right: 2.5rem;
				// box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
				font-family: 'Georgia', serif;

				.term {
					margin-bottom: 1rem;
					border-bottom: 2px solid var(--color-theme-blue-light);
					padding-bottom: 0.5rem;

					.term-text {
						font-size: 2.2rem;
						font-weight: bold;
						color: var(--color-theme-blue-light);
						display: block;
						margin-bottom: 0.25rem;
					}

					.pronunciation {
						font-size: 1.1rem;
						color: #666;
						font-style: italic;
						font-family: 'Times New Roman', serif;
					}
				}

				.part-of-speech {
					font-size: 1rem;
					color: #888;
					font-style: italic;
					margin-bottom: 1rem;
					text-transform: uppercase;
					letter-spacing: 0.5px;
				}

				.definition-text {
					font-size: 1.4rem;
					line-height: 1.6;
					color: var(--color-theme-light);
					text-align: justify;
				}
			}
		}
	}
</style>
