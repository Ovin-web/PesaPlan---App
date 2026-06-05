class TreeNode:
 def __init__(self,value):
    self.value=None
    self.left=None
    self.right=None

class BST:
    def __init__(self):
       self.root=None
    def insert(self,value):
       if root is None:
          return Node(value)
       if value <root.value:
          root.left=insert(root.left,value)
       else:
          root.right=insert(root.right,value)
       return root
         
       
    def search(self,value):
       if root is Node:
          return False
       if root.value==key:
          return True
       elif key<root.value:
          return search (root.left,key)
       else:
          return search(root.right,key)
    
    def inorder(self):
       
       if root:
          inorder(root.left)
          print(root.data,end="")
          inorder(root.right)