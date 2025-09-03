<script>
	import { base } from '$app/paths';
	import { fly, fade } from 'svelte/transition';
</script>

<div class="images-container" out:fade|global={{ duration: 500 }}>
	<img
		src="{base}/assets/images/constitution.jpg"
		alt="Constitution document representing American democracy and civic responsibility"
		in:fly|global={{ delay: 500, x: 500, duration: 1000 }}
	/>
	<img
		src="{base}/assets/images/voting.jpg"
		alt="Voting process showing civic participation and democratic engagement"
		in:fly|global={{ delay: 750, x: -500, duration: 1000 }}
	/>
	<img
		src="{base}/assets/images/flag.jpg"
		alt="American flag symbolizing national identity and civic duty"
		in:fly|global={{ delay: 1000, x: 500, duration: 1000 }}
	/>
</div>

<style lang="scss">
	.images-container {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		align-items: center;
		justify-content: center;
		height: 100vh; // Use full viewport height
		width: 100%;
		padding: 2rem; // Add some padding to prevent images from touching edges

		img {
			flex: 1 1 auto; // Allow images to grow/shrink naturally
			max-height: 25vh; // Limit each image to 25% of viewport height
			width: auto; // Maintain aspect ratio
			object-fit: contain; // Ensure images fit within their container
			// border: 1px solid $color-theme-blue;
			// box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.5);
			background-color: $color-beacon-white;
			// border: 1px solid $color-theme-blue;
			padding: 10px;
			&:nth-of-type(1) {
				transform: translateX(100px);
			}
			&:nth-of-type(2) {
				transform: translateX(-100px);
			}
			&:nth-of-type(3) {
				transform: translateX(100px);
			}
		}
	}
</style>
