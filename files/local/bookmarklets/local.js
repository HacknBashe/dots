var currentUrl = window.location.href;
if (currentUrl.includes("https://app.")) {
  currentUrl = currentUrl.replace("https://app.", "https://local.");
} else if (currentUrl.includes("https://local.")) {
  currentUrl = currentUrl.replace("https://local.", "https://app.");
}
window.open(currentUrl, "_blank");
