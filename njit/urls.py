from django.urls import path
from njit import views

urlpatterns = [
    path('register/', views.RegistrationView.as_view(), name='register'),
    path('section-list/', views.SectionListView.as_view(), name='section-list')
]
