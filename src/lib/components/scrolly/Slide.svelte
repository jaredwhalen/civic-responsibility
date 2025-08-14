<script>
	import { userResponse } from '$lib/stores/userResponse.js';
	import Transition from './Transition.svelte';

	// Template function to replace placeholders with variable values
	function processTemplate(text) {
		if (!text) return '';

		// Create a context object with all available variables
		const context = {
			userResponse: $userResponse.guess.toFixed(0)
		};

		// Replace {variableName} with actual values
		return text.replace(/\{(\w+)\}/g, (match, variableName) => {
			return context[variableName] !== undefined ? context[variableName] : match;
		});
	}

	let { content, cls = '', index, interactiveMode = $bindable() } = $props();
</script>

<section class={`slide ${cls}`} data-index={index}>
	<div class="slide-inner">
		{#if content.id == 'transition'}
			<Transition bind:interactiveMode />
		{/if}
		{#each content?.text.split('\n') as line}
			<p>{processTemplate(line)}</p>
		{/each}
	</div>
</section>

<style lang="scss">
	.slide {
		height: 100vh;
		display: flex;
		align-items: center;
		padding: $spacing-xl 0;

		// &:last-of-type {
		// 	margin-bottom: 100vh;
		// }

		.slide-inner {
			max-width: 500px;
			margin-left: 2rem;
			padding: $spacing-xl;

			// background: #fff;
			// border-radius: $border-radius-lg;
			// width: 100%;
			// margin-left: 2rem;
			// box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);

			font-size: 2rem;
			line-height: 1.5;
			font-weight: 300;
			font-family: $font-family-body;

			p {
				display: inline;
				transition: background-color 0.75s ease;
			}
		}
	}

	:global {
		[data-index='0'] {
			// margin-top: -100vh;
		}

		.slide.transition {
			justify-content: center;
			align-items: end;
			// height: fit-content;

			.slide-inner {
				max-width: 100%;
				height: 100%;
				background: #fff;
				padding: 20vh 5rem;
				background: linear-gradient(
					0deg,
					rgba($color-bg-light, 0) 0%,
					rgba($color-bg-light, 0.75) 20%,
					rgba($color-bg-light, 0.75) 80%,
					rgba($color-bg-light, 0) 100%
				);
				margin: 0px;
				display: flex;
				align-items: center;
				justify-content: center;

				button {
					pointer-events: all;
				}
			}
		}

		// .slide.dashboard-faux {
		// 	height: calc(100vh + 100px);
		// }
	}
</style>
