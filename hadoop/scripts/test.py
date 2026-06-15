import uuid


class BaseModel:

    def __init__(self):
        self.id = uuid.uuid4()
    
    def show_id(self):
        return f"The instance ID is: {self.id}"
    

if __name__ == "__main__":
    new_model = BaseModel()

    print(new_model.show_id())
