<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import Comments from './Comments.svelte';

	// Data for both sections
	const expectedAnswers = [
		{
			text: 'Honoring the Constitution',
			name: 'honoring-the-constitution.png',
			position: {
				top: '5%',
				left: '10%',
				scale: 1
			}
		},
		{
			text: 'Practicing freedom of speech',
			name: 'practicing-freedom-of-speech.png',
			position: {
				top: '40%',
				left: '15%',
				scale: 0.7,
				direction: 'right'
			}
		},
		{
			text: 'Obeying the law',
			name: 'obeying-the-law.png',
			position: {
				top: '30%',
				left: '65%',
				scale: 0.8
			}
		},
		{
			text: 'Paying your taxes',
			name: 'paying-your-taxes.png',
			position: {
				top: '100%',
				left: '15%',
				scale: 1,
				direction: 'right'
			}
		},
		{
			text: 'Serving on a jury',
			name: 'serving-on-a-jury.png',
			position: {
				top: '65%',
				left: '50%',
				scale: 1
			}
		},
		{
			text: 'Voting',
			name: 'voting.png',
			position: {
				top: '100%',
				left: '60%',
				scale: .5,
				direction: 'right'
			}
		}
	];

	const surprisingAnswers = [
		{
			text: 'Tolerating differences',
			name: 'tolerating-differences.png',
			position: {
				top: '15%',
				left: '10%',
				scale: .7,
				direction: 'right'
			}
		},
		{
			text: 'Protecting the environment',
			name: 'protecting-the-environment.png',
			position: {
				top: '30%',
				left: '45%',
				scale: .8
			}
		},
		{
			text: "Helping one's community",
			name: 'helping-ones-community.png',
			position: {
				top: '55%',
				left: '70%',
				scale: .7,
				direction: 'right'
			}
		},
		{
			text: 'Caring for future generations',
			name: 'caring-for-future-generations.png',
			position: {
				top: '50%',
				left: '15%',
				scale: .9
			}
		},
		{
			text: "Making one's voice heard",
			name: 'making-one-s-voice-heard.png',
			position: {
				top: '95%',
				left: '10%',
				scale: .8
			}
		},
		{
			text: 'Being grateful for your opportunities',
			name: 'being-grateful-for-your-opportunities.png',
				position: {
				top: '85%',
				left: '50%',
				scale: .7,
				direction: 'right'
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
			<Comments
				commentData={expectedAnswers}
				progress={comments1Progress}
				startProgress={0}
				endProgress={1}
			/>
		</div>
	</div>

	<!-- Second section: Others surprised us -->
	<div class="section surprising">
		<div class="text-content" bind:this={textElement2}>
			<div class="text-body">Others surprised us</div>
		</div>

		<div class="comments-container" bind:this={commentsElement2}>
			<Comments
				commentData={surprisingAnswers}
				progress={comments2Progress}
				startProgress={0}
				endProgress={1}
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
