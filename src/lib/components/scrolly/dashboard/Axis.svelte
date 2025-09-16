<script>
	let { width, dimensions, axisHeight, tickSize, xScale, inIntro } = $props();
</script>

<div class="axis-container">
	<svg {width} height={axisHeight}>
		<g class="x-axis axis" class:intro={inIntro}>
			<line
				x1={dimensions.margins.left}
				x2={width - dimensions.margins.right}
				stroke="#aaa"
				stroke-width="2"
			/>
			{#each [0, 25, 50, 75, 100] as tickValue}
				<line
					x1={xScale(tickValue)}
					x2={xScale(tickValue)}
					y1={0}
					y2={inIntro ? tickSize * 1.5 : tickSize}
					stroke="#aaa"
					stroke-width="2"
				/>

				<g class="tick" transform="translate({xScale(tickValue)}, {(inIntro ? tickSize * 1.5 : tickSize) / 2})">
					<text y="20" text-anchor="middle">{tickValue}%</text>
				</g>
			{/each}
		</g>
	</svg>
</div>

<style lang="scss">
	svg {
		transition: height 0.5s ease;
	}

	.axis {
		line,
		.tick {
			transition: all 0.5s ease;
		}

		text {
			font-family: $font-family-mono;
		}

		&.intro {
			line {
				stroke-width: 4;
			}

			.tick line {
				stroke-width: 3;
			}

			text {
				font-size: 2rem;
				font-weight: 600;
				alignment-baseline: central;
			}
		}
	}
</style>
