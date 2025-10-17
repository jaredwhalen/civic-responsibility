<script>
	import { X, Facebook, Linkedin, Copy } from '@lucide/svelte';
	import { browser } from '$app/environment';

	let { results } = $props();

	// Toast notification state
	let showToast = $state(false);
	let toastTimeout = $state(null);

	// Generate the social media text based on results
	const socialText = $derived.by(() => {
		let text = 'My civic profile is closest to ';

		// Add age prediction
		if (results.summary) {
			const age = results.summary.find((item) => item.group_var === 'age_binary');
			if (age) {
				text += age.predicted_group === 'old' ? 'an older' : 'a younger';
			}
		}

		text += ' ';

		// Add urban/rural prediction
		if (results.summary) {
			const urban = results.summary.find((item) => item.group_var === 'urban_binary');
			if (urban) {
				text += urban.predicted_group.toLowerCase();
			}
		}

		text += ' ';

		// Add ideology prediction
		if (results.summary) {
			const ideology = results.summary.find((item) => item.group_var === 'ideology_binary');
			if (ideology) {
				text += ideology.predicted_group.toLowerCase();
			}
		}

		text += ". What's your civic profile? Find out at";

		return text;
	});

	// Get current page URL for sharing
	const shareUrl = 'https://civicprofile.us/';

	// Social media sharing functions
	const shareOnX = () => {
		if (!browser) return;
		const url = `https://x.com/intent/post?text=${encodeURIComponent(socialText + ' ' + shareUrl)}`;
		window.open(url, '_blank', 'width=550,height=420');
	};

	const shareOnFacebook = () => {
		if (!browser) return;
		const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`;
		window.open(url, '_blank', 'width=550,height=420');
	};

	const shareOnLinkedIn = () => {
		if (!browser) return;
		const url = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`;
		window.open(url, '_blank', 'width=550,height=420');
	};

	const copyToClipboard = async () => {
		if (!browser) return;
		try {
			await navigator.clipboard.writeText(socialText + ' ' + shareUrl);
			showCopiedMessage();
		} catch (err) {
			console.error('Failed to copy text: ', err);
		}
	};

	const showCopiedMessage = () => {
		showToast = true;

		// Clear any existing timeout
		if (toastTimeout) {
			clearTimeout(toastTimeout);
		}

		// Hide message after 2 seconds
		toastTimeout = setTimeout(() => {
			showToast = false;
		}, 2000);
	};

	const iconSize = 24;
</script>

<div class="social-share-container">
	<!-- Copy Results Button Section -->
	<div class="copy-section">
		<button class="copy-results-button" onclick={copyToClipboard} aria-label="Copy my results">
			<Copy size={20} />
			Copy my results
		</button>
		{#if showToast}
			<span class="copied-message">Copied!</span>
		{/if}
	</div>

	<!-- Share Section -->
	<div class="share-section">
		<h4 class="share-title">Share</h4>
		<div class="social-icons">
			<button class="social-button x" onclick={shareOnX} aria-label="Share on X" title="Share on X">
				<svg
					width="20"
					height="20"
					viewBox="0 0 1200 1227"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
				>
					<path
						d="M714.163 519.284L1160.89 0H1055.03L667.137 450.887L357.328 0H0L468.492 681.821L0 1226.37H105.866L515.491 750.218L842.672 1226.37H1200L714.137 519.284H714.163ZM569.165 687.828L521.697 619.934L144.011 79.6944H306.615L611.412 515.685L658.88 583.579L1055.08 1150.3H892.476L569.165 687.854V687.828Z"
						fill="white"
					/>
				</svg>
			</button>

			<button
				class="social-button facebook"
				onclick={shareOnFacebook}
				aria-label="Share on Facebook"
				title="Share on Facebook"
			>
				<Facebook size={iconSize} />
			</button>

			<button
				class="social-button linkedin"
				onclick={shareOnLinkedIn}
				aria-label="Share on LinkedIn"
				title="Share on LinkedIn"
			>
				<Linkedin size={iconSize} />
			</button>
		</div>

		<p class="share-instructions">
			<em>For Facebook and LinkedIn, copy your results then paste them in the popup window to share!</em>
		</p>
	</div>
</div>

<style lang="scss">
	@import '../../styles/mixins.scss';

	.social-share-container {
		text-align: center;
		margin-top: 2rem;
		padding: 1.5rem;
		background-color: #f8f9fa;
		border-radius: 12px;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			margin-top: 1.5rem;
			padding: 1rem;
			border-radius: 8px;
		}
	}

	.copy-section {
		border-top: 1px solid #dee2e6;
		padding-top: 1.5rem;
		margin-bottom: 1.5rem;
		position: relative;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			margin-bottom: 1rem;
		}
	}

	.copy-results-button {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		background-color: var(--color-theme-blue, #007bff);
		color: white;
		border: none;
		padding: 0.75rem 1.5rem;
		border-radius: 8px;
		font-size: 1rem;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s ease;
		box-shadow: 0 2px 8px rgba(0, 123, 255, 0.2);

		&:hover {
			background-color: #0056b3;
			transform: translateY(-1px);
			box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
		}

		&:active {
			transform: translateY(0);
		}

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding: 0.6rem 1.2rem;
			font-size: 0.9rem;
		}
	}

	.share-section {
		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding-top: 1rem;
		}
	}

	.share-title {
		font-size: 1.1rem;
		font-weight: 600;
		color: #333;
		margin: 0 0 1rem 0;
		text-transform: uppercase;
		letter-spacing: 0.5px;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			font-size: 1rem;
			margin-bottom: 0.8rem;
		}
	}

	.social-icons {
		display: flex;
		justify-content: center;
		gap: 1rem;
		margin-bottom: 1rem;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			gap: 0.5rem;
			margin-bottom: 0.8rem;
		}
	}

	.social-button {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 50px;
		height: 50px;
		border: none;
		border-radius: 50%;
		cursor: pointer;
		transition: all 0.2s ease;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			width: 40px;
			height: 40px;
		}

		&:hover {
			transform: translateY(-2px);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
		}

		&:active {
			transform: translateY(0);
		}

		&.x {
			background-color: #000;
			color: white;

			&:hover {
				background-color: #000;
			}
		}

		&.facebook {
			background-color: #1877f2;
			color: white;

			&:hover {
				background-color: #166fe5;
			}
		}

		&.linkedin {
			background-color: #0077b5;
			color: white;

			&:hover {
				background-color: #005885;
			}
		}
	}

	.copied-message {
		position: absolute;
		left: 50%;
		top: 100%;
		transform: translateX(-50%);
		margin-top: 8px;
		background-color: var(--color-theme-blue, #007bff);
		color: white;
		padding: 4px 8px;
		border-radius: 4px;
		font-size: 12px;
		font-weight: 500;
		white-space: nowrap;
		z-index: 10;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
	}

	.share-instructions {
		font-size: 0.85rem;
		color: #666;
		margin: 0;
		font-style: italic;
		line-height: 1.4;
		max-width: 400px;
		margin: 0 auto;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			font-size: 0.8rem;
			padding: 0 0.5rem;
		}
	}
</style>
