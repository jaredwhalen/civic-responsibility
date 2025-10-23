<script>
	let {
		options,
		activeView,
		variant = 'default',
		clickedSeries = $bindable(),
		interactive = false
	} = $props();
</script>

{#if options?.series && options.series.length > 1}
	<div class="legend" class:large-font={variant === 'large-font'}>
		<!-- <div class="legend-title">Legend</div> -->

		{#if interactive}
			<h3>Legend</h3>
		{/if}

		<div class="legend-items" class:interactive>
			{#each options.series as series, i}
				{#if series.label != 'Other'}
					<div
						class="legend-item"
						class:interactive
						class:active={clickedSeries?.has(series.label)}
						onclick={() => {
							if (interactive) {
								if (clickedSeries?.has(series.label)) {
									const next = new Set(clickedSeries);
									next.delete(series.label);
									clickedSeries = next;
								} else {
									const next = new Set(clickedSeries);
									next.add(series.label);
									clickedSeries = next;
								}
							}
						}}
					>
						<div class="legend-dot" style="background-color: {series.color}"></div>
						<span class="legend-label">{series.label}</span>
					</div>
				{:else}
					<div class="legend-item">
						<div class="legend-dots-cluster">
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
						</div>
						<span class="legend-label">All other groups</span>
					</div>
				{/if}
			{/each}
		</div>
	</div>
{/if}

<style lang="scss">
	.legend {
		// margin-left: 40px;
		// height: 25px;
		.legend-title {
			font-size: 14px;
			font-weight: 800;
			color: #666;
			font-family: sans-serif;
		}

		&.large-font {
			margin-top: 1rem;
			.legend-label {
				font-size: 1.4rem;
			}

			.legend-dot {
				width: 18px;
				height: 18px;
				border: none;
			}

			.legend-items {
				justify-content: center;
			}

			@include mq('mobile', 'max') {
				margin-top: 0rem;
				.legend-label {
					font-size: 1rem;
				}

				.legend-dot {
					width: 12px;
					height: 12px;
					border: none;
				}
			}
		}
	}

	.legend-items {
		display: flex;
		align-items: center;
		column-gap: 1rem;
		row-gap: 0rem;
		flex-wrap: wrap;

		// &.interactive {
		// 	flex-direction: column;
		// 	align-items: flex-start;
		// 	gap: 0.5rem;
		// }
	}

	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		border-bottom: 1px solid transparent;

		&.interactive {
			cursor: pointer;

			&.active,
			&:hover {
				border-bottom: 1px solid var(--color-gray-500);
			}
		}
	}

	.legend-dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		flex-shrink: 0;
		border: 1px solid #aaa;
	}

	.legend-dots-cluster {
		display: flex;
		align-items: center;
		gap: 2px;
		position: relative;
	}

	.legend-dot-small {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		flex-shrink: 0;
		border: 1px solid #aaa;
	}

	.legend-label {
		font-size: 14px;
		font-weight: 500;
		color: #666;
		font-family: sans-serif;
	}

	.instruction {
		font-style: italic;
		@include mq('mobile', 'max') {
			width: 100%;
		}
	}

	h3 {
		font-size: 1rem;
		font-weight: 600;
		margin: 0px 0px 5px;
	}
</style>
