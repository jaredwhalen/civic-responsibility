<script>
	let {
		options,
		activeView,
		variant = 'default',
		clickedSeries = $bindable(),
		interactive = false
	} = $props();
</script>

<div class="legend" class:large-font={variant === 'large-font'}>
	<!-- <div class="legend-title">Legend</div> -->
	<div class="legend-items">
		{#if interactive}
			<span class="legend-item instruction"
				><span class="legend-label">Select dots to compare</span></span
			>
		{/if}

		{#if options?.series && options.series.length > 1}
			{#each options.series as series, i}
				{#if series.label != 'Other'}
					<div
						class="legend-item"
						class:first={i === 0 && interactive}
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
		{/if}
	</div>
</div>

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
	}

	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		border-bottom: 1px solid transparent;

		&.first {
			margin-left: 1rem;
			position: relative;

			&::before {
				content: '';
				margin-right: 1rem;
				color: var(--color-gray-500);
				position: absolute;
				left: -1rem;
				height: 100%;
				border-left: 1px solid var(--color-gray-400);
			}

			@include mq('mobile', 'max') {
				margin-left: 0rem;
				&::before {
					display: none;
				}
			}
		}
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
</style>
