<script>
	import { fade } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';

	const { content } = $props();

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

	// Create a CSS custom property for the show-on-interaction visibility
	$effect(() => {
		if (typeof document !== 'undefined') {
			let el = document.querySelector('.show-on-interaction');
			if (content && el && $userResponse.userSubmitted === true) {
				el.style.display = $userResponse.userSubmitted ? 'inline' : 'none';
			}
		}
	});
</script>

{#key content}
	<div
		class="text-footer"
		class:hide={content.hideFooter}
		out:fade={{ duration: 250 }}
		in:fade={{ delay: 500 }}
	>
		<div class="text-footer__content text-block content">
			{@html content.text
				.split('\r\n')
				.map((p) => `<p>${processTemplate(p)}</p>`)
				.join('')}
		</div>
	</div>
{/key}

<style lang="scss">
	:global {
		.text-footer {
			width: 100%;
			position: absolute;
			bottom: 10%;
			display: flex;
			justify-content: center;
			align-items: center;
			z-index: 1000;
			transition: opacity 0.3s ease;

			&.hide {
				opacity: 0;
			}

			// @include mq('medium') {
			// 	bottom: 20px;
			// }

			&__content {
				width: 100%;
				max-width: 1000px;
				padding: $spacing-xl;
				font-size: 1.7rem;
				line-height: 1.5;
				font-weight: 400;
				font-family: $font-family-body;
				background-color: rgb(236, 241, 250);
				border: 1px solid #999;

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

		// Global style for show-on-interaction elements
		.show-on-interaction {
			display: var(--show-on-interaction-display, none);
		}
	}
</style>
