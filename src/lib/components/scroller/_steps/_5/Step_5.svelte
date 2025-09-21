<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import Comments from './Comments.svelte';

	// Data for both sections
	const expectedAnswers = [
		{
			text: 'Obeying the law',
			position: {
				top: '15%',
				left: '10%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1.7
			}
		},
		{
			text: 'Practicing freedom of speech',
			position: {
				top: '45%',
				left: '15%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1.2
			}
		},
		{
			text: 'Honoring the Constitution',
			position: {
				top: '20%',
				left: '75%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1.4
			}
		},
		{
			text: 'Paying your taxes',
			position: {
				top: '100%',
				left: '15%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1.7
			}
		},
		{
			text: 'Serving on a jury',
			position: {
				top: '65%',
				left: '50%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1
			}
		},
		{
			text: 'Voting',
			position: {
				top: '90%',
				left: '80%',
				color: `${getCSSVar('--color-theme-yellow')}`,
				scale: 1.3
			}
		}
	];

	const surprisingAnswers = [
		{
			text: 'Tolerating differences',
			position: {
				top: '15%',
				left: '10%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1
			}
		},
		{
			text: 'Protecting the environment',
			position: {
				top: '10%',
				left: '75%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1.2
			}
		},
		{
			text: 'Being grateful for your opportunities',
			position: {
				top: '55%',
				left: '70%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1.4
			}
		},
		{
			text: 'Caring for future generation',
			position: {
				top: '50%',
				left: '15%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1.3
			}
		},
		{
			text: "Making one's voice heard",
			position: {
				top: '95%',
				left: '30%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1.1
			}
		},
		{
			text: "Helping one's community",
			position: {
				top: '35%',
				left: '50%',
				color: `${getCSSVar('--color-theme-blue-light')}`,
				scale: 1
			}
		}
	];

	let stepElement;
	let textElement1;
	let commentsElement1;
	let textElement2;
	let commentsElement2;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	// First section: "Some answers we expected" (0-50% of total progress)
	let text1Opacity = $derived(progress >= 10 ? 1 : 0); 
	let text1Y = $derived(progress >= 10 ? 0 : -30); 
	let comments1Progress = $derived(progress >= 15 ? Math.min(1, (progress - 15) / 25) : 0);

	// Second section: "Others surprised us" (50-100% of total progress)
	let text2Opacity = $derived(progress >= 55 ? 1 : 0);
	let text2Y = $derived(progress >= 55 ? 0 : -30);
	let comments2Progress = $derived(progress >= 60 ? Math.min(1, (progress - 60) / 20) : 0);

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states
		gsap.set(textElement1, { opacity: 0, y: -30 });
		gsap.set(textElement2, { opacity: 0, y: -30 });

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
		// First section
		if (textElement1) {
			gsap.to(textElement1, {
				opacity: text1Opacity,
				y: text1Y,
				duration: 0.2,
				ease: 'none'
			});
		}

		// Second section
		if (textElement2) {
			gsap.to(textElement2, {
				opacity: text2Opacity,
				y: text2Y,
				duration: 0.2,
				ease: 'none'
			});
		}
	});
</script>

<div class="step-5" bind:this={stepElement}>
	<!-- First section: Some answers we expected -->
	<div class="section expected">
		<div class="text-content" bind:this={textElement1}>
			<div class="text-body">Some answers we expected</div>
		</div>

		<div class="comments-container" bind:this={commentsElement1}>
			<Comments commentData={expectedAnswers} progress={comments1Progress} startProgress={0} endProgress={1} />
		</div>
	</div>

	<!-- Second section: Others surprised us -->
	<div class="section surprising">
		<div class="text-content" bind:this={textElement2}>
			<div class="text-body text-accent">Others surprised us</div>
		</div>

		<div class="comments-container" bind:this={commentsElement2}>
			<Comments
				commentData={surprisingAnswers}
				progress={comments2Progress}
				startProgress={0}
				endProgress={1}
				direction="right"
			/>
		</div>
	</div>
</div>

<div class="space"></div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-5 {
		position: relative;
		width: 100%;

		.section {
			height: 100vh;
			position: relative;
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: center;
			width: 100%;

			color: var(--color-theme-light);

			.text-content {
				position: sticky;
				top: 50vh;
				transform: translateY(-50%);
				width: 100%;
				padding: 2rem;
				text-align: center;
				z-index: 10;
				max-width: 900px;
				will-change: transform, opacity;
			}

			.text-accent {
				color: var(--color-theme-blue-light);
				font-size: 5rem;
			}

			.comments-container {
				position: sticky;
				// top: 50vh;
				// transform: translateY(-50%);
				width: 100%;
				height: 100%;
				font-family: $font-family-body;
				z-index: 1;
			}
		}
	}

	.space {
		height: 25vh;
	}
</style>
