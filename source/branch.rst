branch
======

Class
-----

.. py:class:: Branch

    Branch class for the BRC algorithm.

    :param down: Given a branch, the lower bound on component states.
    :type down: dict
    :param up: The upper bound on component states.
    :type up: dict
    :param down_state: The system state corresponding to ``down``.
    :type down_state: str of either 's' for survival, 'f' for failure, and 'u' for unknown.
    :param up_state: The system state corresponding to ``up``.
    :type up_state: str of either 's', 'f', and 'u'.
    :param p: The probability of the branch.
    :type p: float

Methods
-------

.. py:method:: Branch.get_compat_rules(self, rules)
   :noindex:

    Get the compatible rules for the branch.

    :param rules: Dictionary of rules.
    :type rules: Dict with keys 's' and 'f', each with a list of survival and failure rules, respectively.
    :return: Compatible rules.
    :rtype: Dict with keys 's' and 'f', each with a list of survival and failure rules, respectively.

.. py:method:: get_cmat(branches, comp_varis)
   :noindex:

    Get the event matrix corresponding to the branches.

    :param branches: List of branches.
    :type branches: list of Branch
    :param comp_varis: List of component variables.
    :type comp_varis: list of Variable
    :return: Event matrix.
    :rtype: 2D np.array

.. py:method:: get_crow(br1, comp_varis)
   :noindex:

    Get the row of the event matrix corresponding to a branch.

    :param br1: Branch.
    :type br1: Branch
    :param comp_varis: List of component variables.
    :type comp_varis: list of Variable
    :return: Row of the event matrix.
    :rtype: 1D np.array

