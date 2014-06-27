Graphite::Engine.routes.draw do

  resources :elective_blocks do
    collection do
      post :create_and_edit
      get :event_pipe
    end
    member do
      patch :enroll
    end

    resources :modules
  end

end
