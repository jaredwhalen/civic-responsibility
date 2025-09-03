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

	let { content, cls = '', index, interactiveMode = $bindable(), noText = false } = $props();

	// Generate accessible slide title and description
	const slideTitle = $derived(content?.title || `Slide ${index + 1}`);
	const slideDescription = $derived(content?.text ? processTemplate(content.text) : '');
	const isTransitionSlide = $derived(content?.id === 'transition');
</script>

<section
	class={`slide ${cls}`}
	data-index={index}
	role="region"
	aria-label={slideTitle}
	aria-describedby="slide-content-{index}"
	aria-live="polite"
>
	{#if !noText}
		<div class="slide-inner" id="slide-content-{index}" role="main" aria-label="Slide content">
			{#if isTransitionSlide}
				<Transition bind:interactiveMode />
			{/if}

			{#if content?.text}
				<div class="slide-text" role="text">
					{#each content.text.split('\n') as line, lineIndex}
						<p
							id="slide-line-{index}-{lineIndex}"
							role="paragraph"
							aria-label="Slide text line {lineIndex + 1}"
						>
							{@html processTemplate(line)}
						</p>
					{/each}
				</div>
			{/if}

			<!-- Screen reader only content for better navigation -->
			<div class="sr-only" aria-hidden="true">
				Slide {index + 1} of content
			</div>
		</div>
	{/if}
</section>

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	.slide {
		height: 100vh;
		display: flex;
		align-items: center;
		padding: $spacing-xl 0;

		&::after {
			content: '';
			position: absolute;
			right: 2.5px;
			width: 10px;
			height: 10px;
			background: #000;
			border-radius: 50%;
			opacity: 0.3;
		}

		// &:last-of-type {
		// 	margin-bottom: 100vh;
		// }

		.slide-inner {
			max-width: 500px;
			margin-left: 4rem;
			padding: $spacing-xl;
			border: 1px solid #999;
			font-size: 1.7rem;
			line-height: 1.5;
			font-weight: 400;
			font-family: $font-family-body;
			background-color: rgb(236, 241, 250);
			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				max-width: 100%;
				margin-left: 0;
				padding: $spacing-md;
			}

			p {
				display: inline;
				transition: background-color 0.75s ease;
				padding: 0.25rem 0px;
			}
		}
	}

	// Screen reader only utility class
	.sr-only {
		position: absolute !important;
		width: 1px !important;
		height: 1px !important;
		padding: 0 !important;
		margin: -1px !important;
		overflow: hidden !important;
		clip: rect(0, 0, 0, 0) !important;
		white-space: nowrap !important;
		border: 0 !important;
	}

	// Focus management for better keyboard navigation
	.slide:focus-within {
		outline: 2px solid rgba(255, 255, 255, 0.3);
		outline-offset: 4px;
	}

	// High contrast mode support
	@media (prefers-contrast: high) {
		.slide-inner {
			border: 2px solid currentColor;
			padding: calc($spacing-xl - 2px);
		}
	}

	// Reduced motion support
	@media (prefers-reduced-motion: reduce) {
		.slide-inner p {
			transition: none;
		}
	}

	:global {
		[data-index='0'] {
			// margin-top: -100vh;
		}

		.slide {
			.slide-inner {
				p {
					span {
						&.underline {
							position: relative;
							z-index: 1;
							width: fit-content;
							display: inline-block;
							&::after {
								content: '';
								display: block;
								width: 100%;
								height: 22px;
								position: absolute;
								bottom: 0px;
								z-index: -1;
							}

							&.yellow {
								&::after {
									background-color: $color-theme-yellow;
									opacity: 0.75;
								}
							}
						}
					}
				}
			}
		}

		.slide.transition {
			justify-content: center;
			align-items: end;
			height: 120vh;

			.slide-inner {
				max-width: 100%;
				height: 100%;
				background: none;
				border: none;

				padding: 20vh 5rem;

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

		span.instructions {
			display: block;
			font-size: 1rem;
			font-family: $font-family-sans;
			margin-top: 20px;

			// Mobile responsive instructions
			@include mq('mobile', 'max') {
				font-size: 0.9rem;
				margin-top: 15px;
			}

			.dot {
				color: $color-theme-red;
			}
		}
	}
</style>
