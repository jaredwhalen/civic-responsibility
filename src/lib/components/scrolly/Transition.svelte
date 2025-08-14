<script>
	let { interactiveMode = $bindable() } = $props();
</script>

<div class="transition">
	<div>
		<button data-button="explore" onclick={() => (interactiveMode = true)}>Click here</button> to explore
		how the data breaks down along demographic lines, gender, location, and more.
	</div>
	<div>
		Or take our <button data-button="quiz">interactive quiz</button> to see how your beliefs compare
		to those of other Americans.
	</div>
</div>

<style lang="scss">
	button {
		color: $color-beacon-dark-green;
		padding: 0.25rem 0.5rem;
		border-radius: 10px;
		border: none;
		cursor: pointer;
		display: inline-block;
		font-size: inherit;

		&[data-button='explore'] {
			background: $color-beacon-light-green;
		}
		&[data-button='quiz'] {
			background: $color-beacon-yellow;
		}
	}

	.transition {
		display: flex;

		gap: 3rem;
		align-items: center;
		justify-content: center;
		height: 100%;
		width: 100%;

		background: linear-gradient(
			0deg,
			rgba($color-bg-light, 0) 0%,
			rgba($color-bg-light, 0.75) 20%,
			rgba($color-bg-light, 0.75) 80%,
			rgba($color-bg-light, 0) 100%
		);
		margin: 0px;
	}
</style>
