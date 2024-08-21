document.addEventListener('turbo:load', function() {
  const stars = document.querySelectorAll('#rating .fa');
  const ratingValue = document.getElementById('rating-value');
  
  stars.forEach(star => {
    star.addEventListener('mouseover', function() {
      resetStars();
      highlightStars(this.getAttribute('data-value'));
    });
  
    star.addEventListener('mouseout', function() {
      resetStars();
      highlightStars(ratingValue.value);
    });
  
    star.addEventListener('click', function() {
      ratingValue.value = this.getAttribute('data-value');
      highlightStars(ratingValue.value);
    });
  });
  
  function highlightStars(rating) {
    stars.forEach(star => {
      if (star.getAttribute('data-value') <= rating) {
          star.classList.add('selected');
      }
    });
  }
  
  function resetStars() {
    stars.forEach(star => {
      star.classList.remove('selected', 'hover');
    });
  }

  document.querySelectorAll('.reply-link').forEach(function(link) {
    link.addEventListener('click', function(event) {
      event.preventDefault();
      var target = document.getElementById(link.dataset.target);
      if (target.style.display === 'none') {
        target.style.display = 'block';
      } else {
        target.style.display = 'none';
      }
    });
  });
});
