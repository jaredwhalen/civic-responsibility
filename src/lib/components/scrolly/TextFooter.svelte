<script>
	import { fly } from 'svelte/transition';
	import { userResponse } from '$lib/stores/userResponse.js';
	import GroupLegend from '../dashboard/GroupLegend.svelte';
	import { getCSSVar } from '$lib/helpers/getCSSVar';

	const { content } = $props();

	const components = {
		GroupLegend: GroupLegend
	};

	const options = $derived([
		{
			label: 'Generation',
			value: 'generation',
			series: [
				{ label: 'Gen Z', color: getCSSVar('--color-theme-blue') },
				{ label: 'Baby Boomers', color: getCSSVar('--color-theme-yellow') }
			]
		},
		{
			label: 'Political Identification',
			value: 'pid',
			series: [
				{ label: 'Democrats', color: getCSSVar('--color-theme-dem-blue') },
				{ label: 'Republicans', color: getCSSVar('--color-theme-gop-red') }
			]
		}
	]);

	let ActiveComponent = $derived(content.component ? components[content.component.id] : null);

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
				// el.style.display = $userResponse.userSubmitted ? 'inline' : 'none';

				let userGuess = $userResponse.guess.toFixed(0);
				// If user guess is 87, replace content with "Good job!"
				if (userGuess == 87) {
					el.textContent = "That's right!";
				}
			}
		}
	});
</script>

{#key content}
	<div
		class="text-footer"
		class:hide={content.hideFooter}
		in:fly={{ y: -50, duration: 400, delay: 200 }}
		out:fly={{ y: 50, duration: 300 }}
	>
		<div class="text-footer__content text-block content">
			{@html content.text
				.split('\r\n')
				.map((p) => `<p>${processTemplate(p)}</p>`)
				.join('')}
		</div>

		{#if ActiveComponent}
			<div class="text-footer__component">
				<ActiveComponent options={options.find((o) => o.value === content.component.series)} variant={content?.component?.variant} />
			</div>
		{/if}
	</div>
{/key}

<style lang="scss">
	:global {
		.text-footer {
			width: 100%;
			position: absolute;
			top: 15%;
			display: flex;
			justify-content: center;
			z-index: 1000;
			transition: opacity 0.3s ease;
			flex-direction: column;
			max-width: 1000px;
			margin: 0 auto;
			left: 0;
			right: 0;
			text-align: center;
			&.hide {
				opacity: 0;
			}

			// @include mq('medium') {
			// 	bottom: 20px;
			// }

			&__content {
				width: 100%;

		
				font-size: 2rem;
				line-height: 1.5;
				font-weight: 400;
				font-family: $font-family-body;
				// background-color: rgb(236, 241, 250);
				// border: 1px solid #999;

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

					span {
						&.underline {
							position: relative;
							z-index: 1;
							width: fit-content;
							display: inline-block;
							font-weight: 600;
						}
					}
				}
			}
		}

		// // Global style for show-on-interaction elements
		// .show-on-interaction {
		// 	display: var(--show-on-interaction-display, none);
		// }
	}
</style>
